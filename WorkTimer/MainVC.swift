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
    
    
    @IBOutlet weak var barContentView: UIView! {
        didSet {
            barContentView.layer.cornerRadius = 5
            barContentView.layer.shadowColor = UIColor.gray.cgColor
        }
    }
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
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
            destinationLabel.text = UserDefaultsManager.destinationAdress
        }
    }
    @IBOutlet weak var searchLocationBtn: UIButton! {
        didSet {
            searchLocationBtn.layer.cornerRadius = 5
        }
    }
    
    
    
    @IBOutlet weak var endTimeLabel: UILabel! {
        didSet {
            endTimeLabel.textColor = UIColor.gray
            endTimeLabel.text = defaultTimeString
        }
    }
    
    @IBOutlet weak var saveTimeBtn: UIButton! {
        didSet {
            saveTimeBtn.layer.cornerRadius = 5
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
        
        self.startTimeLabel.text = setTimeInfo()
        setTimeInfoColor(timeText: self.startTimeLabel.text ?? defaultTimeString)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        destinationLabel.text = UserDefaultsManager.destinationAdress
        findAddress(location: locationManager.location)
    }
    
    
    @IBAction func resetBtnAction(_ sender: Any) {
        UserDefaultsManager.workStartTime = ""
        self.startTimeLabel.text = setTimeInfo()
        setTimeInfoColor(timeText: self.startTimeLabel.text ?? defaultTimeString)
    }
    
    @IBAction func searchLocationBtnAction(_ sender: Any) {
        guard let welcomeVC =  self.storyboard?.instantiateViewController(withIdentifier: "searchLocationVC") as? searchLocationVC else {return}
            
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true, completion: nil)
    }
    
    @IBAction func saveTimeBtnAction(_ sender: Any) {
        endTimeLabel.text = DateManager.shared.getTimeToString(Date())
        endTimeLabel.textColor = UIColor.black
        
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
            self.startTimeLabel.textColor = UIColor.gray
        } else {
            self.startTimeLabel.textColor = UIColor.black
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
    
    func compareDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let to = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return from.distance(from: to)
    }
    
    func getAdress(placemarks : [CLPlacemark]?) -> String {
        var address = ""
        
        if let place = placemarks?.first {
            if let thoroughfare = place.thoroughfare {
                address = "\(address) \(thoroughfare)"
            }
            
            if let subThoroughface = place.subThoroughfare {
                address = "\(address) \(subThoroughface)"
            }
        }
        return address
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
        if let location = location {
            geocoder.reverseGeocodeLocation(location) { [self] placemarks,error in
                if error != nil { return }
                
                self.currentLabel.text = getAdress(placemarks: placemarks)
                
                if self.startTimeLabel.text == defaultTimeString {
                        
                    let cLocation : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                        
                    if let dLat = UserDefaultsManager.destinationLatitude, let dLon = UserDefaultsManager.destinationLongitude{
                            
                        let dLocation = CLLocationCoordinate2D(latitude: dLat, longitude: dLon)
                        
                        let distance = compareDistance(from: cLocation, to: dLocation)
                            
                        if distance <= 10 {
                                UserDefaultsManager.workStartTime = DateManager.shared.getDataToString(Date())
                                self.startTimeLabel.text = self.setTimeInfo()
                                setTimeInfoColor(timeText: self.startTimeLabel.text ?? defaultTimeString)
                                NotificationManager.shared.requestSendNoti(timer: UserDefaultsManager.workStartTime)
                        }
                    }
                }
            }
        }
    }
}

