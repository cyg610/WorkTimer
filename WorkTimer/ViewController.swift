//
//  ViewController.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/16.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    
    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var timeInfoLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton! {
        didSet {
            resetButton.layer.cornerRadius = 5
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
        
        self.timeInfoLabel.text = UserDefaultsManager.workStartTime
            
    }
    
    @IBAction func resetBtnAction(_ sender: Any) {
        UserDefaultsManager.workStartTime = ""
    }
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func getLocationUsagePermission() {
           self.locationManager.requestWhenInUseAuthorization()
           self.locationManager.allowsBackgroundLocationUpdates = true
       }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //위도, 경도 가져오기
        currentLocation = "\(locValue.latitude), \(locValue.longitude)"
        findAddress(location: manager.location)
        
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
            geocoder.reverseGeocodeLocation(location!) {placemarks,error in
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
                
                    if self.timeInfoLabel.text == "", (address.contains("대치동") || address.contains("테헤란로")) {
                        
                        UserDefaultsManager.workStartTime = DateManager.shared.getDataToString(Date())
                        self.timeInfoLabel.text = UserDefaultsManager.workStartTime
                        NotificationManager.shared.requestSendNoti(timer: UserDefaultsManager.workStartTime)

                    }
                    
                    
                 }
            }
        }
    }
}

