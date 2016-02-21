MessagePack
==========

[![Zewo 0.2](https://img.shields.io/badge/Zewo-0.2-FE3762.svg?style=flat)](http://new.zewo.io)
[![Swift 2.2](https://img.shields.io/badge/Swift-2.2-orange.svg?style=flat)](https://swift.org)
[![Platform Linux](https://img.shields.io/badge/Platform-Linux-lightgray.svg?style=flat)](https://swift.org)
[![License MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat)](https://tldrlegal.com/license/mit-license)
[![Slack Status](https://zewo-slackin.herokuapp.com/badge.svg)](http://slack.zewo.io)

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

[![Slack](http://s13.postimg.org/ybwy92ktf/Slack.png)](http://slack.zewo.io)

Join us on [Slack](http://slack.zewo.io).

License
-------

**MessagePack** is released under the MIT license. See LICENSE for details.
