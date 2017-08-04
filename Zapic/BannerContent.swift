//
//  WelcomeBanner.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/7/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation
import UIKit

class ZapicBanner: UIView {

  let content = UIView()

  init(contentRightPadding: Int? = nil, icon: UIImage?) {

    super.init(frame: .zero)

    backgroundColor = UIColor.white

    self.translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalToConstant: 320).isActive = true

    self.layer.cornerRadius = 5

    let colorBar = ColorBar()

    //Color bar across the top
    self.addSubview(colorBar)

    var img = icon
    //Zapic icon
    if img == nil {
      img = ZapicImages.image(name: "ZapicLogo")
    }

    let iconView = UIImageView(image: img)
    iconView.contentMode = .scaleAspectFit
    iconView.layer.cornerRadius = 5
    iconView.layer.masksToBounds = true

    addSubview(iconView)

    let iconPadding: CGFloat = 8
    iconView.translatesAutoresizingMaskIntoConstraints = false
    iconView.topAnchor.constraint(equalTo: colorBar.bottomAnchor, constant: iconPadding ).isActive = true
    iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: iconPadding).isActive = true
    iconView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -iconPadding).isActive = true
    iconView.widthAnchor.constraint(equalTo: iconView.heightAnchor).isActive = true

    addSubview(content)

    let contentPadding: CGFloat = 5
    let rightPadding = CGFloat(contentRightPadding ?? 0)
    content.translatesAutoresizingMaskIntoConstraints = false
    content.topAnchor.constraint(equalTo: colorBar.bottomAnchor, constant: contentPadding).isActive = true
    content.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -contentPadding).isActive = true
    content.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -(contentPadding + rightPadding)).isActive = true
    content.leftAnchor.constraint(equalTo: iconView.rightAnchor, constant: contentPadding).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class MessageBannerView: ZapicBanner {

  init(_ text: String, icon: UIImage?) {

    super.init(icon:icon)

    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.text = text
    label.numberOfLines = 2
    label.textAlignment = .center

    content.addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
    label.centerYAnchor.constraint(equalTo: content.centerYAnchor).isActive = true
    label.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

class NotificationBannerView: ZapicBanner {

  init(title: String, text: String, icon: UIImage?) {

    super.init(contentRightPadding:20, icon:icon)

    //Title
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 13)
    titleLabel.text = title
    titleLabel.textAlignment = .center

    content.addSubview(titleLabel)

    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    titleLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
    titleLabel.topAnchor.constraint(equalTo: content.topAnchor).isActive = true
    titleLabel.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
    titleLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true

    //Text
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 16)
    label.text = text
    label.textAlignment = .center

    content.addSubview(label)

    label.translatesAutoresizingMaskIntoConstraints = false
    label.centerXAnchor.constraint(equalTo: content.centerXAnchor).isActive = true
    label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
    label.bottomAnchor.constraint(equalTo: content.bottomAnchor).isActive = true
    label.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
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
