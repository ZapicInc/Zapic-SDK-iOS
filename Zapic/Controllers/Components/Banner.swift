//
// Banner.swift
// Zapic
//
// Created by Daniel Sarfati on 8/2/17.
// Copyright © 2017 zapic. All rights reserved.
//
//
// Banner.swift
//
// Created by Harlan Haskins on 7/27/15.
// Copyright (c) 2015 Bryx. All rights reserved.
//

import UIKit

private enum BannerState {
  case showing, hidden, gone
}

/// A level of 'springiness' for Banners.
///
/// - None: The banner will slide in and not bounce.
/// - Slight: The banner will bounce a little.
/// - Heavy: The banner will bounce a lot.
enum BannerSpringiness {
  case none, slight, heavy
  fileprivate var springValues: (damping: CGFloat, velocity: CGFloat) {
    switch self {
    case .none: return (damping: 1.0, velocity: 1.0)
    case .slight: return (damping: 0.7, velocity: 1.5)
    case .heavy: return (damping: 0.6, velocity: 2.0)
    }
  }
}

/// Banner is a dropdown notification view that presents above the main view controller, but below the status bar.
class Banner: UIView {
  private func topWindow() -> UIView? {
    let root = UIApplication.shared.delegate?.window??.rootViewController

    if let presented = root?.presentedViewController {
      return presented.view
    }

    return root?.view
  }

  /// How long the slide down animation should last.
  var animationDuration: TimeInterval = 0.4

  /// How 'springy' the banner should display. Defaults to `.Slight`
  var springiness = BannerSpringiness.slight

  /// The height of the banner.
  var bannerHeight: CGFloat = 66

  /// Whether or not the banner should show a shadow when presented.
  var hasShadows = true {
    didSet {
      resetShadows()
    }
  }

  /// A block to call when the uer taps on the banner.
  var didTapBlock: (() -> Void)?

  let bannerContent: UIView

  /// A block to call after the banner has finished dismissing and is off screen.
  var didDismissBlock: (() -> Void)?

  /// Whether or not the banner should dismiss itself when the user taps. Defaults to `true`.
  var dismissesOnTap = true

  /// Whether or not the banner should dismiss itself when the user swipes up. Defaults to `true`.
  var dismissesOnSwipe = true

  private var bannerState = BannerState.hidden {
    didSet {
      if bannerState != oldValue {
        forceUpdates()
      }
    }
  }

  /// A Banner with the provided `title`, `subtitle`, and optional `image`, ready to be presented with `show()`.
  ///
  /// - parameter title: The title of the banner. Optional. Defaults to nil.
  /// - parameter subtitle: The subtitle of the banner. Optional. Defaults to nil.
  /// - parameter image: The image on the left of the banner. Optional. Defaults to nil.
  /// - parameter backgroundColor: The color of the banner's background view. Defaults to `UIColor.blackColor()`.
  /// - parameter didTapBlock: An action to be called when the user taps on the banner. Optional. Defaults to `nil`.
  required init(title: String, subtitle: String? = nil, icon: UIImage? = nil, didTapBlock: (() -> Void)? = nil) {
    self.didTapBlock = didTapBlock

    if let subText = subtitle {
      bannerContent = NotificationBannerView(title: title, text: subText, icon: icon)
    } else {
      bannerContent = MessageBannerView(title, icon: icon)
    }

    super.init(frame: CGRect.zero)

    resetShadows()
    addGestureRecognizers()
    initializeSubviews()
  }

  private func forceUpdates() {
    guard let superview = superview, let showingConstraint = showingConstraint, let hiddenConstraint = hiddenConstraint else { return }
    switch bannerState {
    case .hidden:
      superview.removeConstraint(showingConstraint)
      superview.addConstraint(hiddenConstraint)
    case .showing:
      superview.removeConstraint(hiddenConstraint)
      superview.addConstraint(showingConstraint)
    case .gone:
      superview.removeConstraint(hiddenConstraint)
      superview.removeConstraint(showingConstraint)
      superview.removeConstraints(commonConstraints)
    }
    setNeedsLayout()
    setNeedsUpdateConstraints()
    // Managing different -layoutIfNeeded behaviours among iOS versions (for more, read the UIKit iOS 10 release notes)
    if #available(iOS 10.0, *) {
      superview.layoutIfNeeded()
    } else {
      layoutIfNeeded()
    }
    updateConstraintsIfNeeded()
  }

  @objc internal func didTap(_ recognizer: UITapGestureRecognizer) {
    if dismissesOnTap {
      dismiss()
    }
    didTapBlock?()
  }

  @objc internal func didSwipe(_ recognizer: UISwipeGestureRecognizer) {
    if dismissesOnSwipe {
      dismiss()
    }
  }

  private func addGestureRecognizers() {
    addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(Banner.didTap(_:))))
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(Banner.didSwipe(_:)))
    swipe.direction = .up
    addGestureRecognizer(swipe)
  }

  private func resetShadows() {
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = self.hasShadows ? 0.5 : 0.0
    layer.shadowOffset = CGSize(width: 0, height: 0)
    layer.shadowRadius = 4
  }

  private var contentTopOffsetConstraint: NSLayoutConstraint!

  private func initializeSubviews() {

    var extraPadding: CGFloat = 0

    if UIDevice.current.iPhoneX &&  UIDevice.current.isPortrait {
      extraPadding = 30
    }

    self.translatesAutoresizingMaskIntoConstraints = false
    self.heightAnchor.constraint(equalToConstant: bannerHeight + extraPadding).isActive = true

    addSubview(bannerContent)

    bannerContent.heightAnchor.constraint(equalToConstant: bannerHeight).isActive = true
    bannerContent.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    bannerContent.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private var showingConstraint: NSLayoutConstraint?
  private var hiddenConstraint: NSLayoutConstraint?
  private var commonConstraints = [NSLayoutConstraint]()

  override func didMoveToSuperview() {
    super.didMoveToSuperview()
    guard let superview = superview, bannerState != .gone else { return }
    self.centerXAnchor.constraint(equalTo: superview.centerXAnchor).isActive = true
    showingConstraint = self.topAnchor.constraint(equalTo: superview.topAnchor)
    let yOffset: CGFloat = -7.0 // Offset the bottom constraint to make room for the shadow to animate off screen.
    hiddenConstraint = self.bottomAnchor.constraint(equalTo: superview.topAnchor, constant: yOffset)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    layoutIfNeeded()
  }

  /// Shows the banner. If a view is specified, the banner will be displayed at the top of that view, otherwise at top of the top window. If a `duration` is specified, the banner dismisses itself automatically after that duration elapses.
  /// - parameter view: A view the banner will be shown in. Optional. Defaults to 'nil', which in turn means it will be shown in the top window. duration A time interval, after which the banner will dismiss itself. Optional. Defaults to `nil`.
  func show(duration: TimeInterval? = nil) {
    guard let view = topWindow() else {
      ZLog.error("Could not find view. Aborting.")
      return
    }
    view.addSubview(self)
    forceUpdates()
    let (damping, velocity) = self.springiness.springValues
    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .allowUserInteraction, animations: {
      self.bannerState = .showing
    }, completion: { _ in
      guard let duration = duration else { return }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(1000.0 * duration))) {
        self.dismiss()
      }
    })
  }

  /// Dismisses the banner.
  func dismiss() {
    let (damping, velocity) = self.springiness.springValues
    UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: velocity, options: .allowUserInteraction, animations: {
      self.bannerState = .hidden
    }, completion: { _ in
      self.bannerState = .gone
      self.removeFromSuperview()
      self.didDismissBlock?()
    })
  }
}
