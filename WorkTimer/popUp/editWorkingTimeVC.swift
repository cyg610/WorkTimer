//
//  editWorkingTimeVC.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/05/07.
//

import Foundation
import UIKit


class editWorkingTimeVC : UIViewController {
    
    @IBOutlet weak var popupTItleLabel: UILabel! {
        didSet {
            popupTItleLabel.text = "업무 시간을 입력하세요."
        }
    }
    @IBOutlet weak var editTextField: UITextField! {
        didSet {
            editTextField.text = UserDefaultsManager.workStartTime
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel! {
        didSet {
            timeLabel.text = "시간"
        }
    }
    
    @IBOutlet weak var okBtn: UIButton! {
        didSet {
            okBtn.setTitle("확인", for: .normal)
        }
    }
    
    override func viewDidLoad() {
        
    }
    
    func initView() {
        
        
    }
    
    
    @IBAction func okBtnAction(_ sender: Any) {
        
        if let workTime : Int = Int(editTextField.text ?? "7") {
            UserDefaultsManager.workingTime = workTime
         
        }
        
        self.dismiss(animated: true)
    }
    
}
