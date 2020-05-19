//
//  JMSettingItemsTableViewCell.swift
//  Jimu
//
//  Created by Sam   on 2019/6/25.
//  Copyright © 2019 ubt. All rights reserved.
//

import UIKit
import SnapKit

enum cellTpyes {
    
    case normal
    case hasSwitch
    case rightArrow
    case rightTitle
}

class SettingItemsTableViewCell: UITableViewCell {
    
    // MARK: - property
    
    ///设置cell类型
    var cellTpye:cellTpyes{
        
        didSet {
            
            switch cellTpye {
                case .normal:
                    rightArrow.isHidden = true
                    rightLabel.isHidden = true
                    my_switch.isHidden = true
                
                case .hasSwitch:
                    rightArrow.isHidden = true
                    rightLabel.isHidden = true
                    my_switch.isHidden = false
                
                case .rightTitle:
                    rightArrow.isHidden = true
                    rightLabel.isHidden = false
                    my_switch.isHidden = true
                
                case .rightArrow:
                    rightArrow.isHidden = false
                    rightLabel.isHidden = true
                    my_switch.isHidden = true
            }
        }
    }
    
    ///设置按钮开关
    var turnOn: Bool {
        
        didSet{
            my_switch.isOn = turnOn
        }
    }
    
    ///按钮点击反馈
    var feedbackSwitchBlock:((_ btn: Bool)->())?
    
    ///左边文字
    var titleName: String? {
        
        didSet {
            self.titleLabel.text = titleName
        }
    }
    ///右边文字
    var rightText: String? {
        
        didSet {
            self.rightLabel.text = rightText
        }
    }
    ///右边文字颜色
    var rightTextColor: UIColor?{
        didSet{
            self.rightLabel.textColor = rightTextColor
        }
    }
    ///左边文字颜色
    var leftTextColor: UIColor?{
        didSet{
            self.titleLabel.textColor = leftTextColor
        }
    }
    
    private lazy var layerView: UIView = {
        let v = UIView.init()
        v.backgroundColor = UIColor.white
        v.layer.shadowOpacity = 0.08
        return v
    }()
    
    private lazy var titleLabel: UILabel = {
        let l = UILabel.init()
        l.textColor = UIColor.black
        return l
    }()
    
    private lazy var rightLabel: UILabel = {
        let l = UILabel.init()
        l.textColor = UIColor.blue
        return l
    }()
    
    private lazy var my_switch: UISwitch = {
        let s = UISwitch.init()
        s.addTarget(self, action: #selector(switchValueChanged(_ :)), for: .valueChanged)
        return s
    }()
    
    //箭头
    private lazy var rightArrow: UIImageView = {
       let imageview = UIImageView()
        imageview.image = UIImage(named: "arrow_right")
        return imageview
    }()
    
    // MARK: - method
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        
        cellTpye = cellTpyes.normal
        turnOn = true
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = UITableViewCell.SelectionStyle.none
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension SettingItemsTableViewCell{
    
    private func setupUI() {
        
        if #available(iOS 11.0, *) {
            contentView.backgroundColor = UIColor.init(named: "#FAFAFC")
        } else {
            // Fallback on earlier versions
        }
        contentView.addSubview(layerView)
        layerView.addSubview(titleLabel)
        layerView.addSubview(rightLabel)
        layerView.addSubview(my_switch)
        layerView.addSubview(rightArrow)
        

    }
    // MARK: - 按钮点击
    @objc private func switchValueChanged(_ sender: UISwitch) {
        guard let block = feedbackSwitchBlock else { return }
        block(my_switch.isOn)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layerView.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset((30))
            make.width.lessThanOrEqualTo((450))
            make.top.bottom.equalToSuperview()
        }
        rightArrow.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset((-30))
            make.width.equalTo((16))
            make.height.equalTo((26))
        }
        rightLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset((-30))
            make.width.lessThanOrEqualTo((160))
        }
        my_switch.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-30)
            make.width.equalTo(50)
            make.height.equalTo(30)
            
        }
        
    }
}
