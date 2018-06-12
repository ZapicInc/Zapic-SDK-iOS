//
//  File.swift
//  Zapic
//
//  Created by Daniel Sarfati on 7/11/17.
//  Copyright © 2017 Zapic. All rights reserved.
//

import Foundation

class ZapicView: UIView {

  var controllerDelegate: ZapicViewControllerDelegate?

  let title = UILabel()
  let colorBar = ColorBar()

  init(text: String, showSpinner: Bool = false) {

    super.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))

    backgroundColor = ZapicColors.background

    //Color bar

    addSubview(colorBar)

    //Zapic icon
    let icon = UIImageView(image: ZapicImages.image(name: "ZapicLogo"))
    icon.contentMode = .scaleAspectFit

    self.addSubview(icon)

    let iconSize: CGFloat = 64
    icon.translatesAutoresizingMaskIntoConstraints = false
    icon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    icon.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -150).isActive = true
    icon.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
    icon.widthAnchor.constraint(equalToConstant: iconSize).isActive = true

    var lastAnchor = icon.bottomAnchor

    if showSpinner {
      //Spinner
      let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
      self.addSubview(spinner)
      spinner.translatesAutoresizingMaskIntoConstraints = false
      spinner.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 15).isActive = true
      spinner.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
//      spinner.heightAnchor.constraint(equalToConstant: iconSize).isActive = true
//      spinner.widthAnchor.constraint(equalToConstant: iconSize).isActive = true
      spinner.startAnimating()

      lastAnchor = spinner.bottomAnchor
    }

    //Text label
    title.font = UIFont.systemFont(ofSize: 22)
    title.text = text
    title.textAlignment = .center
    title.textColor = ZapicColors.primaryText

    self.addSubview(title)

    title.translatesAutoresizingMaskIntoConstraints = false
    title.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    title.topAnchor.constraint(equalTo: lastAnchor, constant: 15).isActive = true

    //Close button
    let closeButton = UIButton()
    closeButton.setTitle("Done", for: .normal)
    closeButton.setTitleColor(ZapicColors.primaryText, for: .normal)

    closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)

    self.addSubview(closeButton)

    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.topAnchor.constraint(equalTo: colorBar.bottomAnchor).isActive = true
    closeButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func closeButtonAction(sender: UIButton!) {
    ZLog.info("Close button tapped")
    controllerDelegate?.closePage()
  }
}
