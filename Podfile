# Type `pod update --no-repo-update` to update repos.
# Need to copy `https://raw.githubusercontent.com/SVGKit/SVGKit/2.x/SVGKit.podspec`
# to `~/.cocoapods/repos/master/Specs/SVGKit/2.0/` to use the lastest version of SVGKit.

platform :ios, '6.0'

xcodeproj 'TestView/TestView.xcodeproj'

pod 'TouchVG', :podspec => 'https://raw.githubusercontent.com/touchvg/vgios/develop/podspec/TouchVG.podspec'

pre_install do |installer|
  projfile = "TestView/TestView.xcodeproj/project.pbxproj"
  
  if File.exists?(projfile)
    File.open("proj.tmp", "w") do |io|
      io << File.read(projfile).gsub(/((OTHER_LDFLAGS)|(HEADER_SEARCH_PATHS)|(LIBRARY_SEARCH_PATHS)) =([\s]|[^;])*;[\s]*/, '')
    end
    FileUtils.mv("proj.tmp", projfile)
    system 'rm -fR TestView.xcworkspace'
  end
end
