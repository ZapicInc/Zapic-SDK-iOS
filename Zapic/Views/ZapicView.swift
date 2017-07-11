//
//  File.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/11/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import RxSwift

class ZapicView: UIView {
    let closeSub = PublishSubject<Bool>()

    let icon = UIImageView(image: ZapicImages.image(name: "ZapicLogo"))
    let title = UILabel()

    init(_ text: String) {

        super.init(frame: .zero)

        backgroundColor = ZapicColors.background

        icon.contentMode = .scaleAspectFit
        self.addSubview(icon)

        let iconSize = 128

        icon.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-100)
            make.height.equalTo(iconSize)
            make.width.equalTo(iconSize)
        }

        //Loading text
        title.font = UIFont.systemFont(ofSize: 22)
        title.text = text
        title.textAlignment = .center
        title.textColor = ZapicColors.primaryText
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(icon.snp.bottom)
        }

        //Close button
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)

        self.addSubview(button)

        button.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(20)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func buttonAction(sender: UIButton!) {
        print("Close button clicked")
        closeSub.onNext(true)
    }
}
