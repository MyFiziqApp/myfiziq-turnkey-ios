#
#  MyFiziqTurnkey
#
#  Copyright (c) 2018-2020 MyFiziq. All rights reserved.
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

Pod::Spec.new do |s|
  s.name             = 'MyFiziqTurnkey'
  s.version          = '19.1.9'
  s.summary          = 'MyFiziq Turnkey integration template'
  s.description      = <<-DESC
Optional submodule that provides a generic template drop-in integration solution (a.k.a turnkey solution).
                       DESC

  s.homepage         = 'https://myfiziq.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE.md' }
  s.author           = { 'MyFiziq' => 'dev@myfiziq.com' }
  s.source           = { :git => 'https://github.com/MyFiziqApp/myfiziq-turnkey-ios.git', :branch => '19.1.9_trunk' }
  s.social_media_url = 'https://twitter.com/MyFiziq'

  s.ios.deployment_target = '12.1'

  s.source_files = 'MyFiziqTurnkey/Classes/**/*'
  s.public_header_files = 'MyFiziqTurnkey/Classes/Public/*.h'
  s.private_header_files = 'MyFiziqTurnkey/Classes/Private/*.h'
  
  s.resource_bundles = {
    'MyFiziqTurnkeyResources' => ['MyFiziqTurnkey/Assets/*.css', 'MyFiziqTurnkey/Assets/*.m4a', 'MyFiziqTurnkey/Assets/*.caf', 'MyFiziqTurnkey/Assets/*.xml','MyFiziqTurnkey/Assets/*.storyboard','MyFiziqTurnkey/Assets/*.xib','MyFiziqTurnkey/Assets/*.xcassets','MyFiziqTurnkey/Assets/*.strings']
  }

  s.frameworks = [
    "Foundation",
    "QuartzCore",
    "UIKit"
  ]
  s.dependency 'MyFaCSS', '~> 19.1.0'
  s.dependency 'MyFiziqSDKCommon', '~> 19.1.0'
  s.dependency 'MyFiziqSDKBilling', '~> 19.1.0'
  s.dependency 'MyFiziqSDK', '~> 19.1.5'
  s.dependency 'MyFiziqSDKLoginView', '~> 19.1.0'
  s.dependency 'MyFiziqSDKSupport', '~> 19.1.0'
  s.dependency 'MyFiziqSDKOnboardingView', '~> 19.1.0'
  s.dependency 'MyFiziqSDKTrackingView', '~> 19.1.0'
  s.dependency 'MyFiziqSDKProfileView', '~> 19.1.0'
  s.dependency 'MyFiziqSDKInputView', '~> 19.1.0'
  
end
