#
# Be sure to run `pod lib lint FloatingActionButton.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "FloatingActionButton"
  s.version          = "1.0"
  s.summary          = "Material Design Floating Action Button"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                      Material Design Floating Action Button in liquid state inspired by http://www.materialup.com/posts/material-in-a-liquid-state
                        Floating Action Button adapted from LiquidFloatingActionButton from https://github.com/yoavlt/LiquidFloatingActionButton
                       DESC

  s.homepage         = "https://github.com/TeletronicsDotAe/FloatingActionButton"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Martin Jacob Rehder" => "rehscopods_01@rehsco.com" }
  s.source           = { :git => "https://github.com/TeletronicsDotAe/FloatingActionButton.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '10.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  #s.resource_bundles = {
  #  'FloatingActionButton' => ['Pod/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
