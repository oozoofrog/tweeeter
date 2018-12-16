# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def tests
    pod 'RxTest'
    pod 'Quick'
    pod 'Nimble'
end

target 'Tweeeter' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Tweeeter

  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'SnapKit'
  pod 'SwiftLint'
  pod 'FlexLayout'
  pod 'PinLayout'
  pod 'SDWebImage'

  target 'TweeeterTests' do
    inherit! :search_paths
    # Pods for testing
    tests
  end

  target 'TweeeterUITests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'APITests' do
      inherit! :search_paths
      # Pods for testing
      tests
  end

end
