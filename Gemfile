source "https://rubygems.org"

# fastlane >= 2.227.0 is required for Xcode 16+ xcresulttool support
gem "fastlane", ">= 2.227.0"


plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
