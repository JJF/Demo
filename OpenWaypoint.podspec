    Pod::Spec.new do |s|
    s.name = "OpenWaypoint"
    s.version = "0.0.2"
    s.summary = "添加测试Demo"
    s.description = <<-DESC
            添加测试Demo的工具
    DESC
    s.homepage = "https://github.com/JJF/Demo"
    s.license = { :type => "MIT", :file => "LICENSE" }
    s.author = { "JJF" => "cyrys@163.com" }
    s.platform = :ios, "9.0"
    s.source = { :git => "https://github.com/JJF/Demo.git", :tag => "0.0.2" }
    s.source_files = "OpenWaypoint", "OpenWaypoint/**/*.{h,m}"
    s.framework = "UIKit"
    s.framework = "XCTest"

  s.swift_version = '5.0'                            #支持的swift版本

    end