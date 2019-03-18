Pod::Spec.new do |spec|
  spec.name         = 'QuickPaySDK'
  spec.version      = '0.1'
  spec.summary      = 'QuickPay is a web based Payment Service Provider, allowing you to accept payments online.'
  spec.homepage     = 'http://quickpay.net'

  spec.authors      = 'QuickPay'
  spec.license      = { :type => 'Apache-2.0', :file => 'LICENSE' }

  spec.platform     = :ios
  spec.source       = { :git => 'https://github.com/QuickPay/ios-sdk-pod.git', :tag => 'v0.1' }

  spec.ios.deployment_target = '11.0'
  spec.ios.framework   = 'Foundation', 'UIKit', 'WebKit'
  spec.ios.vendored_frameworks = 'QuickPaySDK.framework'
end
