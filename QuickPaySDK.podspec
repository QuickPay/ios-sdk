Pod::Spec.new do |spec|
  spec.name         = 'QuickPaySDK'
  spec.version      = '1.1.0'
  spec.summary      = 'QuickPay is a web based Payment Service Provider, allowing you to accept payments online.'
  spec.homepage     = 'http://quickpay.net'

  spec.authors      = 'QuickPay'
  spec.license      = { :type => 'EULA', :file => 'LICENSE' }

  spec.platform     = :ios
  spec.source       = { :git => 'https://github.com/QuickPay/ios-sdk-pod.git', :tag => 'v1.1.0' }

  spec.ios.deployment_target = '11.0'
  spec.ios.framework   = 'Foundation', 'UIKit', 'WebKit'
  spec.ios.vendored_frameworks = 'QuickPaySDK.framework'
end
