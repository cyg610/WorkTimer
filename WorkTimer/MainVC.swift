//
//  ViewController.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/16.
//

import UIKit
import CoreLocation
import GoogleMaps


class MainVC: UIViewController {
    
    let defaultTimeString = "00:00:00"
    
    let currentMarker = GMSMarker() // 마커 객체 생성
    var locationLatitude : CLLocationDegrees = 0
    var locationLongitude : CLLocationDegrees = 0
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var googleMapView: GMSMapView! {
        didSet {
            currentMarker.icon = #imageLiteral(resourceName: "redMarker")
            currentMarker.map = googleMapView // 마커를 표시할 맵
        }
    }
    
    @IBOutlet weak var currentIconImageView: UIImageView!
    
    @IBOutlet weak var destinationLabel: UILabel! {
        didSet {
            destinationLabel.text = UserDefaultsManager.destinationLocation
        }
    }
    @IBOutlet weak var searchLocationBtn: UIButton! {
        didSet {
            searchLocationBtn.layer.cornerRadius = 5
        }
    }
    
    
    var locationManager = CLLocationManager.init()
    var geocoder = CLGeocoder.init()
    var currentLocation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        locationManager.delegate =  self
        getLocationUsagePermission()
        NotificationManager.shared.requestAuthNoti()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        self.timeInfoLabel.text = setTimeInfo()
        setTimeInfoColor(timeText: self.timeInfoLabel.text ?? defaultTimeString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        destinationLabel.text = UserDefaultsManager.destinationLocation
    }
    
    
    @IBAction func resetBtnAction(_ sender: Any) {
        UserDefaultsManager.workStartTime = ""
        self.timeInfoLabel.text = setTimeInfo()
        setTimeInfoColor(timeText: self.timeInfoLabel.text ?? defaultTimeString)
    }
    
    @IBAction func searchLocationBtnAction(_ sender: Any) {
        guard let welcomeVC =  self.storyboard?.instantiateViewController(withIdentifier: "searchLocationVC") as? searchLocationVC else {return}
            
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true, completion: nil)
    }
    
    
    func setTimeInfo() -> String{
        if let timer = UserDefaultsManager.workStartTime, timer != "" {
            let timeArray = timer.split(separator: " ")
            return String(timeArray[1])
        }else {
            return defaultTimeString
        }
    }
    
    func setTimeInfoColor(timeText : String) {
        if timeText == defaultTimeString {
            self.timeInfoLabel.textColor = UIColor.gray
        } else {
            self.timeInfoLabel.textColor = UIColor.black
        }
    }
    
    func setCurrentMarker() {
    
        currentMarker.position = CLLocationCoordinate2D(latitude: locationLatitude, longitude: locationLongitude)
        // 마커의 위치를 현재 위도, 경도로 설정
    }
    
    func setGoogleMap() {
        let camera = GMSCameraPosition(latitude: locationLatitude, longitude: locationLongitude, zoom: 17) //현재 위도, 경도로 카메라를 이동, 줌 레벨(확대되는 정도)는 17로 설정
        googleMapView.camera = camera
    }
    
}

extension MainVC: CLLocationManagerDelegate {
    
    func getLocationUsagePermission() {
           self.locationManager.requestWhenInUseAuthorization()
           self.locationManager.allowsBackgroundLocationUpdates = true
       }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //위도, 경도 가져오기
        locationLatitude = locValue.latitude
        locationLongitude = locValue.longitude
        currentLocation = "\(locValue.latitude), \(locValue.longitude)"
        findAddress(location: manager.location)
        
        setGoogleMap()
        setCurrentMarker()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("GPS 권한 설정됨")
                    self.locationManager.startUpdatingLocation() // 중요!
                case .restricted, .notDetermined:
                    print("GPS 권한 설정되지 않음")
                    getLocationUsagePermission()
                case .denied:
                    print("GPS 권한 요청 거부됨")
                    getLocationUsagePermission()
                default:
                    print("GPS: Default")
                }
    }
    
    func findAddress(location : CLLocation?) {
        if location != nil {
            geocoder.reverseGeocodeLocation(location!) { [self]placemarks,error in
                if error != nil { return }
                
                if let placemarks = placemarks?.first {
                    var address = ""
                    
                    if let thoroughfare = placemarks.thoroughfare {
                        address = "\(address) \(thoroughfare)"
                    }
                    
                    if let subThoroughface = placemarks.subThoroughfare {
                        address = "\(address) \(subThoroughface)"
                    }
                    
                   
                    self.currentLabel.text = address
                    if self.timeInfoLabel.text == defaultTimeString {
                        
                        UserDefaultsManager.workStartTime = DateManager.shared.getDataToString(Date())
                        self.timeInfoLabel.text = self.setTimeInfo()
                        setTimeInfoColor(timeText: self.timeInfoLabel.text ?? defaultTimeString)
                        NotificationManager.shared.requestSendNoti(timer: UserDefaultsManager.workStartTime)

                    }
                    
                    
                 }
            }
        }
    }
}

