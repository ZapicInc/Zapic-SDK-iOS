Pod::Spec.new do |s|
    s.name         = 'Zapic'
    s.version      = '0.1.0'
    s.license      = { :type => 'MIT', :file => 'LICENSE' }
    s.homepage     = 'https://zapic.com'
    s.summary      = 'Client SDK to connect iOS apps to the Zapic platform.'
    s.authors      = { 'Daniel Sarfati' => 'daniel@zapic.com' }

    s.source       = { :git => 'https://github.com/ZapicInc/Zapic-SDK-iOS.git', :tag => s.version.to_s }

    s.platform     = :ios
    s.ios.deployment_target = '9.0'

    s.source_files = "Zapic", "Zapic/**/*.{h,m,swift}"
    s.public_header_files = "Zapic/*.h"
    s.resource_bundles = { 'Zapic' => 'Zapic/ZapicAssets.xcassets'}

    s.pod_target_xcconfig = { 'SWIFT_VERSION' => '3' }
    s.dependency 'NotificationBannerSwift'
    s.dependency 'PromiseKit', '~> 4.0'
end
