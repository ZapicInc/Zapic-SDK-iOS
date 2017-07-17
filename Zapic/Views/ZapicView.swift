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
    
    internal let title = UILabel()
    
    private let closeButton = UIButton()
    private let bag = DisposeBag()
    private let icon = UIImageView(image: ZapicImages.image(name: "ZapicLogo"))
    private let viewModel:ZapicViewModel

    init(_ viewModel:ZapicViewModel, text: String) {
        self.viewModel = viewModel
        
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
        closeButton.setTitle("Done", for: .normal)

        self.addSubview(closeButton)

        closeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.top.equalToSuperview()
        }
        
        bindToViewModel()
    }
    
    private func bindToViewModel(){
        //Connect to the close button
        self.closeButton.rx.tap.subscribe(onNext: {
            self.viewModel.closeWindow()
        }).addDisposableTo(bag)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
