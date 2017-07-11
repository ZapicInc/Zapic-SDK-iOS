//
//  OfflineView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/11/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit

class OfflineView: UIView {
    
    init() {
        
        super.init(frame: .zero)
        
        backgroundColor = ZapicColors.background
        
        //Zapic icon
        let img = ZapicImages.image(name: "ZapicLogo")
        let imageView = UIImageView(image: img)
        imageView.contentMode = .scaleAspectFit
        
        self.addSubview(imageView)
        
        let iconSize = 128
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.height.equalTo(iconSize)
            make.width.equalTo(iconSize)
        }
        
        //Offline text
        let loading = UILabel()
        loading.font = UIFont.systemFont(ofSize: 22)
        loading.text = "Could Not Connect"
        loading.textAlignment = .center
        loading.textColor = ZapicColors.primaryText
        self.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
        }
        
        //Offline text
        let details = UILabel()
        details.font = UIFont.systemFont(ofSize: 18)
        details.text = "Please check your network connection and try again"
        details.textAlignment = .center
        details.lineBreakMode = .byWordWrapping
        details.numberOfLines = 0 //Unlimited number of lines
        details.textColor = ZapicColors.secondaryText
        self.addSubview(details)
        details.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(50)
            make.right.equalToSuperview().offset(-50)
            make.top.equalTo(loading.snp.bottom).offset(10)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
