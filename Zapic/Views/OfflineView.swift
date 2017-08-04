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
    super.init(text: "Could Not Connect")

    //Offline text
    let details = UILabel()
    details.font = UIFont.systemFont(ofSize: 18)
    details.text = "Please check your network connection and try again"
    details.textAlignment = .center
    details.lineBreakMode = .byWordWrapping
    details.numberOfLines = 0 //Unlimited number of lines
    details.textColor = ZapicColors.secondaryText

    addSubview(details)

    details.translatesAutoresizingMaskIntoConstraints = false
    details.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 50).isActive = true
    details.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -50).isActive = true
    details.topAnchor.constraint(equalTo: self.title.bottomAnchor, constant: 10).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
