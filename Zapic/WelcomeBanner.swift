//
//  WelcomeBanner.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/7/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

import UIKit
import SnapKit

class WelcomeBannerView: UIView {

    let colorBar: ColorBar = ColorBar()

    init() {

        super.init(frame: .zero)
        
        backgroundColor = UIColor.white.withAlphaComponent(0.9)
        
        self.addSubview(colorBar)
        
        colorBar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.right.equalToSuperview()
            make.left.equalToSuperview()
        }

        //Text
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 22)
        title.text = "Welcome back to Zapic"
        title.textAlignment = .center
        self.addSubview(title)
        title.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(colorBar.frame.height/2)
        }

        //Zapic icon
        let img = ZapicImages.image(name: "ZapicLogo")
        let imageView = UIImageView(image: img)
        imageView.contentMode = .scaleAspectFit

        self.addSubview(imageView)

        let padding = 2

        imageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(padding)
            make.right.equalTo(title.snp.left)
            make.bottom.equalToSuperview().offset(-padding)
            make.height.equalTo(imageView.snp.width)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ZapicImages {
    private static let zBundle =  Bundle(for: ZapicImages.self)

    static func image(name: String) -> UIImage? {
        return UIImage(named: name, in: zBundle, compatibleWith: nil)
    }
}

class ZapicColor {
    static let blue = UIColor(red:0.00, green:0.87, blue:0.68, alpha:1.0)
    static let green = UIColor(red:0.00, green:0.52, blue:0.89, alpha:1.0)

}

class ColorBar: UIView {

    let gradient = CAGradientLayer ()

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 8))
        self.layer.insertSublayer(gradient, at: 0)
        gradient.frame = CGRect(x: 0, y: 0, width: 320, height: 8)
        gradient.colors = [ZapicColor.blue.cgColor, ZapicColor.green.cgColor, ZapicColor.blue.cgColor, ZapicColor.green.cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint =  CGPoint.zero
        gradient.locations = [-2.0, -1.0, 0.0, 1]

        animate()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func animate() {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.toValue = [0.0, 1.0, 2.0, 3.0]
        animation.duration = 3.0
        animation.repeatCount = Float.infinity
        gradient.add(animation, forKey: nil)
    }

    override func layoutSubviews() {
        gradient.frame.size.width = self.frame.width
    }
}
