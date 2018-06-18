Pod::Spec.new do |s|
    s.name         = 'Zapic'
    s.version      = '1.2.0'
    s.license      = "MIT"
    s.homepage     = 'https://www.zapic.com'
    s.summary      = 'Client SDK to connect iOS apps to the Zapic platform.'
    s.authors      = { 'Daniel Sarfati' => 'daniel@zapic.com' }
    s.source       = { :git => 'https://github.com/ZapicInc/Zapic-SDK-iOS.git', :tag => "#{s.version}" }
    s.platform     = :ios, "9.0"
    s.source_files = "Zapic", "Zapic/**/*.{h,m,swift}"
    s.swift_version = '4.1'
end
