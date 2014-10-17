Pod::Spec.new do |spec|
  spec.name         = 'M13InfiniteTabbar'
  spec.version      = '2.3.1'
  spec.license      = { :type => 'BSD' }
  spec.homepage     = 'https://github.com/willseward/M13InfiniteTabBar'
  spec.authors      = { 'Wills Ward' => 'wward@warddevelopment.co' }
  spec.summary      = 'ARC and GCD Compatible Reachability Class for iOS and OS X.'
  spec.source       = { :git => 'https://github.com/willseward/M13InfiniteTabBar', :branch => 'iOS-8-Updates' }
  spec.source_files = 'M13InfiniteTabBar.{h,m}'
  spec.framework    = 'SystemConfiguration'
end

