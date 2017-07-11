//
//  OfflineView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/11/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit

class OfflineView: ZapicView {

    init() {

        super.init("Could Not Connect")

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
            make.top.equalTo(title.snp.bottom).offset(10)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
