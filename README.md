MessagePack
==========

[![Travis][travis-image]][travis-url]
[![Zewo][zewo-image]][zewo-url]
[![Swift][swift-badge]][swift-url]
[![Platform][platform-badge]][platform-url]
[![License][mit-badge]][mit-url]
[![Slack][slack-badge]][slack-url]

**MessagePack** is an efficient binary serialization format. It lets you exchange data among multiple languages like JSON. But it's faster and smaller. Small integers are encoded into a single byte, and typical short strings require only one extra byte in addition to the strings themselves.

## Usage

```swift
import MessagePack

let packed = pack(.UInt(42))
//packed is [0x2a]
let unpacked = try? unpack([0x2a])
//unpacked is 42

let packed = pack([0, 1, 2, 3, 4]) 
//packed is [0x95, 0x00, 0x01, 0x02, 0x03, 0x04]

...

//you can find more examples in Tests folder
```

## Installation

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/antonmes/MessagePack.git", majorVersion: 0, minor: 2)
    ]
)
```

## Community

[![Slack][slack-image]][slack-url]

Join us on [Slack](http://slack.zewo.io).

License
-------

**MessagePack** is released under the MIT license. See LICENSE for details.

[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[platform-badge]: https://img.shields.io/badge/Platform-Mac%20%26%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-url]: http://slack.zewo.io
[travis-image]: https://travis-ci.org/antonmes/MessagePack.svg?branch=master
[travis-url]: https://travis-ci.org/antonmes/MessagePack
[zewo-image]: https://img.shields.io/badge/Zewo-0.3-FE3762.svg?style=flat
[zewo-url]: http://zewo.io
