# Deprecation Notice

This repository is deprecated by Duo Security.  The repository will remain public and visible, and integrations built using this repository’s code will continue to work.  You can also continue to fork, clone, or pull from this repository.

However, Duo will not provide any further releases or enhancements.

---

# DuoAPISwift

DuoAPISwift is an API client to call Duo API methods with Swift.

If you have a feature request or a bug to report, please contact support@duo.com.

Otherwise, if you have specific questions about how to use this library or want to make it better, please open an issue here in Github or submit a pull request as needed. We do not have ETA's on when pull requests will get merged in, but we will do our best to take a look at them as soon as possible.

## Duo Auth API

The [Duo Auth API][1] provides a low-level API for adding strong two-factor authentication to applications that cannot directly display rich web content.

## Installation

### TLS 1.2 and 1.3 Support

All recent releases of the various Apple OSes support TLS 1.2 and 1.3.

### CocoaPods

To install DuoAPISwift with [CocoaPods][2], add the following line to your `Podfile`.

```
pod 'DuoAPISwift', '~> 2.0'
```

Then run `pod install` to add DuoAPISwift to your project.

### Carthage

To install DuoAPISwift with Carthage, add the following to your `Cartfile`.

```
github "duosecurity/duo_api_swift" ~> 2.0
```

Then run `carthage update` to build the framework. When finished, drag `DuoAPISwift.framework` to your Xcode project.

## Usage

### Creating the Auth Object

```
import DuoAPISwift

let auth = Auth(
    ikey: "<IKEY>",
    skey: "<SKEY (Keep this secret!)>",
    host: "api-xxxxxxxx.duosecurity.com")
```

### Verify that Duo Is Up and Running

```
auth.ping({response in
    print(response)
})
```

### Verify IKEY, SKEY, and Signature

```
auth.check({response in
    print(response)
})
```

### Retrieve Stored Logo

```
auth.logo({ response in
    if let data = response as? NSData {
        if let image = NSImage(data: data as Data) {
            self.logoImageView.image = image
        }
    }
})
```

### Send a Duo Push Authentication Request

```
auth.auth("push",
          username: "<USERNAME>",
          device: "auto",
          completion: { response in
    var allowed = false
    if let r = response["response"] as? [String : Any],
            let result = r["result"] as? String {
        if result == "allow" {
            allowed = true
        }
    }
    if allowed {
        print("Success. Logging you in...")
    } else {
        print("Access denied.")
    }
})
```

[1]: https://duo.com/docs/authapi
[2]: https://cocoapods.org/
