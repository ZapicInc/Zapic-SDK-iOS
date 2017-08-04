//
//  ColorBar.swift
//  Zapic
//
//  Created by Daniel Sarfati on 8/3/17.
//  Copyright © 2017 zapic. All rights reserved.
//

import Foundation

class ColorBar: UIView {

  private let gradient = CAGradientLayer ()

  init() {
    super.init(frame: CGRect.zero)
    backgroundColor = .red
    self.layer.insertSublayer(gradient, at: 0)
    gradient.colors = [ZapicColors.blue.cgColor, ZapicColors.green.cgColor, ZapicColors.blue.cgColor, ZapicColors.green.cgColor]
    gradient.startPoint = CGPoint(x: 1, y: 0)
    gradient.endPoint =  CGPoint.zero
    gradient.locations = [-2.0, -1.0, 0.0, 1]

//    animate()
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
    gradient.frame.size.height = self.frame.height
  }

  override func didMoveToWindow() {
    animate()
  }

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    guard let superview = superview else {return}

    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
    self.heightAnchor.constraint(equalToConstant: 6).isActive = true
    self.leadingAnchor.constraint(equalTo: superview.leadingAnchor).isActive = true
    self.trailingAnchor.constraint(equalTo: superview.trailingAnchor).isActive = true
  }
}
