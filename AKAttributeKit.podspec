#
# Be sure to run `pod lib lint AKAttributeKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "AKAttributeKit"
  s.version          = "0.3.0"
  s.summary          = "NSAttributedString with no hassle, just fun! Add attributes more like HTML tags right into the string."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
                        When it comes to styling texts in iOS or OSX, NSAttributedString is
                        the genie we got. But unfortunately the ginie doesn't talk much english
                        and often we are about to avoid it so.
                        Here comes AKAttributeKit to rescue. It uses HTML-ish tags in your string
                        to create expected NSAttributedString in no time. Use the same native
                        NSAttributedString without the hassle of adding attributes with verbose
                        not-so-readable code.
                       DESC

  s.homepage         = "https://github.com/ashikahmad/AKAttributeKit"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Ashik uddin Ahmad" => "ashikcu@gmail.com" }
  s.source           = { :git => "https://github.com/ashikahmad/AKAttributeKit.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/ashik_ahmad'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  # s.resource_bundles = {
  #   'AKAttributeKit' => ['Pod/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
