# MyFiziq Turnkey : iOS

![MyFiziq Turnkey Solution](turn-key.png)

MyFiziq Turnkey is intended to be a base template that can be forked and customised according to the integration planned. This saves developers the need to implement boilerplate integration code for adding MyFiziq technology to an existing app.

## Installation

### CocoaPod Configuration

You can add MyFiziq Turnkey as a drop in SDK to an existing project by adding as a pod to the project's CocoaPods Podfile:

As MyFiziq SDKs have not yet been publicly released, the private repository will need to be configured with Cocoapods. Run the following command in Terminal to install the MyFiziq private repo:

```sh
pod repo add myfiziq-private https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/myfiziq-sdk-podrepo
```

In the App Podfile, declare the private repository by adding the following lines at the top (this includes the public Cocoapods repository):

```ruby
source 'https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/myfiziq-sdk-podrepo'
source 'https://cdn.cocoapods.org/'
```

Now that Cocoapods has been configured with the MyFiziq private repository, the MyFiziq Turnkey SDK can be included as a target to the App Podfile. Add the following to the Podfile to the appropriate App target:

```ruby
pod "MyFiziqTurnkey"
```

Finally, run the Cocoapods install command:

```sh
pod install
```

### Customisation Configuration

The MyFiziq Turnkey:iOS solution is simply a convience solution on how an app could integrate the MyFiziq technology. However, it is perfectly acceptable to use Turnkey as a template base, which you can fork and alter accordingly to achieve the particular style and behaviour that is intended:

1. Fork the MyFiziq Turnkey:iOS repo to a new repo, from GitHub repo `https://github.com/MyFiziqApp/myfiziq-turnkey-ios`.
2. Make alterations as need to the code base and make custom styling as needed to meet the needs on the integration.
3. In the partner App, update the Podfile to add the Turnkey (reccommend as a direct git link). Eg: `pod "MyFiziqTurnkey", :git => 'https://github.com/EXAMPLE/myfiziq-turnkey-ios.git', :branch => '19.1.9_trunk'`.

## Getting Started

Please refer to the example project (in `https://github.com/MyFiziqApp/myfiziq-turnkey-ios/Example`) on an example integration.

1. Be sure to add the Profile Card UIView (the turnkey gateway) into the partner app.
2. Add the MyFiziq Turnkey initialisation to App start-up and link the user authentication/authorisation accordingly.
3. Run search for `// TURNKEY EXAMPLE` comment to find all app bindings of the Turnkey solution.

## Example App

To run the Example App project, clone the repo and run pod install from the Example directory:

```ruby
git clone https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/myfiziq-turnkey-ios --recusive
cd myfiziq-turnkey-ios/Example/
pod install
```

This project is based on the MyFiziqSDK Boilperplate example, but it doesn't use the MyFiziq SDKs directly so that the project is as similar to a partner app as possible (uses alternative idp, not the one provided as convience by the MyFiziq Core SDK).

## Author

MyFiziq iOS Dev, dev@myfiziq.com

## License

MyFiziqSDK is Copyright 2016-2020.

