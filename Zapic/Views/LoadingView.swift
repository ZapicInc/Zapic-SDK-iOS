//
//  LoadingView.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/10/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import WebKit

class LoadingView: UIView {

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
            make.centerY.equalToSuperview().offset(-iconSize/2)
            make.height.equalTo(iconSize)
            make.width.equalTo(iconSize)
        }

        //Loading text
        let loading = UILabel()
        loading.font = UIFont.systemFont(ofSize: 22)
        loading.text = "Loading..."
        loading.textAlignment = .center
        loading.textColor = ZapicColors.primaryText
        self.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom)
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
