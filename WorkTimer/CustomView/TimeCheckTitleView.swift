//
//  TimeCheckTitleView.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/10/19.
//

import Foundation
import UIKit

class TimeCheckTitleView : UIView {
    
    @IBOutlet weak var timerImageView: UIImageView! {
        didSet {
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = "근무시간"
            titleLabel.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var valueLabel: UILabel! {
        didSet {
            valueLabel.text = "\(UserDefaultsManager.workingTime!) 시간"
            valueLabel.textColor = UIColor.white
        }
    }
    
    @IBOutlet weak var chartImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadView()
    }
    
    private func loadView() {
        let view = Bundle.main.loadNibNamed("TimeCheckTitleView",
                                            owner: self,
                                            options: nil)?.first as! UIView
        view.frame = bounds
        addSubview(view)
    }
    
}
