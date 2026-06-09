Pod::Spec.new do |spec|
  spec.name         = "TidepoolKit"
  spec.version      = "1.0.0"
  spec.summary      = "An iOS framework for communicating with the Tidepool platform."
  spec.description  = <<-DESC
    TidepoolKit provides OAuth2/OIDC authentication and a full API client
    for the Tidepool diabetes data platform.
  DESC

  spec.homepage     = "https://github.com/tidepool-org/TidepoolKit"
  spec.license      = { :type => "BSD-2-Clause", :file => "LICENSE" }
  spec.author       = { "Tidepool" => "support@tidepool.org" }
  spec.platform     = :ios, "15.1"
  spec.source       = { :git => "https://github.com/tidepool-org/TidepoolKit.git", :branch => "dev" }
  spec.source_files = "Sources/TidepoolKit/**/*.swift"
  spec.swift_version = "5.7"
end
