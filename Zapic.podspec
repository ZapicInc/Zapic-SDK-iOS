Pod::Spec.new do |s|
    s.name         = 'Zapic'
    s.version      = '2.0.1'
    s.license      = "MIT"
    s.homepage     = 'https://www.zapic.com'
    s.summary      = 'Client SDK to connect iOS apps to the Zapic platform.'
    s.authors      = { 'Daniel Sarfati' => 'daniel@zapic.com' }
    s.source       = { :git => 'https://github.com/ZapicInc/Zapic-SDK-iOS.git', :tag => "#{s.version}" }
    s.platform     = :ios, "9.0"
    s.source_files = "Zapic", "Zapic/**/*.{h,m,swift}"
end
