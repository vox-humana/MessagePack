import Data

/// Joins bytes from the generator to form an integer.
///
/// - parameter generator: The input generator to unpack.
/// - parameter size: The size of the integer.
///
/// - returns: An integer representation of `size` bytes of data.
func unpackInteger<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, size: Int) throws -> UInt64 {
    var value: UInt64 = 0
    for _ in 0..<size {
        if let byte = iterator.next() {
            value = value << 8 | numericCast(byte)
        } else {
            throw MessagePackError.InsufficientData
        }
    }

    return value
}

/// Joins bytes from the generator to form a string.
///
/// - parameter generator: The input generator to unpack.
/// - parameter length: The length of the string.
///
/// - returns: A string representation of `size` bytes of data.
func unpackString<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, length: Int) throws -> String {
    var bytes = Data()
    bytes.reserveCapacity(length)

    for _ in 0..<length {
        if let byte = iterator.next() {
            bytes.append(byte)
        } else {
            throw MessagePackError.InsufficientData
        }
    }

    if let result = try? String(data: bytes) {
        return result
    } else {
        throw MessagePackError.InvalidData
    }
}

/// Joins bytes from the generator to form a data object.
///
/// - parameter generator: The input generator to unpack.
/// - parameter length: The length of the data.
///
/// - returns: A subsection of data representing `size` bytes.
func unpackData<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, length: Int) throws -> Data {
    var data = Data()
    data.reserveCapacity(length)

    for _ in 0..<length {
        if let byte = iterator.next() {
            data.append(byte)
        } else {
            throw MessagePackError.InsufficientData
        }
    }

    return data
}

/// Joins bytes from the generator to form an array of `MessagePackValue` values.
///
/// - parameter generator: The input generator to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An array of `count` elements.
func unpackArray<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, count: Int, compatibility: Bool) throws -> [MessagePackValue] {
    var values = [MessagePackValue]()
    values.reserveCapacity(count)

    for _ in 0..<count {
        let value = try unpack(&iterator, compatibility: compatibility)
        values.append(value)
    }

    return values
}

/// Joins bytes from the generator to form a dictionary with entires of `MessagePackValue` keys/values.
///
/// - parameter generator: The input generator to unpack.
/// - parameter count: The number of elements to unpack.
///
/// - returns: An dictionary of `count` entries.
func unpackMap<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, count: Int, compatibility: Bool) throws -> [MessagePackValue : MessagePackValue] {
    var dict = [MessagePackValue : MessagePackValue](minimumCapacity: count)
    var lastKey: MessagePackValue? = nil

    let array = try unpackArray(&iterator, count: 2 * count, compatibility: compatibility)
    for item in array {
        if let key = lastKey {
            dict[key] = item
            lastKey = nil
        } else {
            lastKey = item
        }
    }

    return dict
}

/// Unpacks a byte generator into a MessagePackValue.
///
/// - parameter generator: The input generator to unpack.
///
/// - returns: A `MessagePackValue`.
public func unpack<G: IteratorProtocol where G.Element == Byte>(iterator: inout G, compatibility: Bool = false) throws -> MessagePackValue {
    if let value = iterator.next() {
        switch value {

        // positive fixint
        case 0x00...0x7f:
            return .UInt(numericCast(value))

        // fixmap
        case 0x80...0x8f:
            let count = Int(value - 0x80)
            let dict = try unpackMap(&iterator, count: count, compatibility: compatibility)
            return .Map(dict)

        // fixarray
        case 0x90...0x9f:
            let count = Int(value - 0x90)
            let array = try unpackArray(&iterator, count: count, compatibility: compatibility)
            return .Array(array)

        // fixstr
        case 0xa0...0xbf:
            let length = Int(value - 0xa0)
            if compatibility {
                let data = try unpackData(&iterator, length: length)
                return .Binary(data)
            } else {
                let string = try unpackString(&iterator, length: length)
                return .String(string)
            }


        // nil
        case 0xc0:
            return .Nil

        // false
        case 0xc2:
            return .Bool(false)

        // true
        case 0xc3:
            return .Bool(true)

        // bin 8, 16, 32
        case 0xc4...0xc6:
            let size = 1 << numericCast(value - 0xc4)
            let length = try unpackInteger(&iterator, size: size)
            let subdata = try unpackData(&iterator, length: numericCast(length))
            return .Binary(subdata)

        // ext 8, 16, 32
        case 0xc7...0xc9:
            let size = 1 << Int(value - 0xc7)
            let length = try unpackInteger(&iterator, size: size)
            if let typeByte = iterator.next() {
                let type = Int8(bitPattern: typeByte)
                let data = try unpackData(&iterator, length: numericCast(length))
                return .Extended(type, data)
            } else {
                throw MessagePackError.InsufficientData
            }

        // float 32
        case 0xca:
            let bytes = try unpackInteger(&iterator, size: 4)
            let float = unsafeBitCast(UInt32(truncatingBitPattern: bytes), to: Float.self)
            return .Float(float)

        // float 64
        case 0xcb:
            let bytes = try unpackInteger(&iterator, size: 8)
            let double = unsafeBitCast(bytes, to: Double.self)
            return .Double(double)

        // uint 8, 16, 32, 64
        case 0xcc...0xcf:
            let size = 1 << (numericCast(value) - 0xcc)
            let integer = try unpackInteger(&iterator, size: size)
            return .UInt(integer)

        // int 8
        case 0xd0:
            if let byte = iterator.next() {
                let integer = Int8(bitPattern: byte)
                return .Int(numericCast(integer))
            } else {
                throw MessagePackError.InsufficientData
            }

        // int 16
        case 0xd1:
            let bytes = try unpackInteger(&iterator, size: 2)
            let integer = Int16(bitPattern: UInt16(truncatingBitPattern: bytes))
            return .Int(numericCast(integer))

        // int 32
        case 0xd2:
            let bytes = try unpackInteger(&iterator, size: 4)
            let integer = Int32(bitPattern: UInt32(truncatingBitPattern: bytes))
            return .Int(numericCast(integer))

        // int 64
        case 0xd3:
            let bytes = try unpackInteger(&iterator, size: 8)
            let integer = Int64(bitPattern: bytes)
            return .Int(integer)

        // fixent 1, 2, 4, 8, 16
        case 0xd4...0xd8:
            let length = 1 << Int(value - 0xd4)
            if let typeByte = iterator.next() {
                let type = Int8(bitPattern: typeByte)
                let bytes = try unpackData(&iterator, length: length)
                return .Extended(type, bytes)
            } else {
                throw MessagePackError.InsufficientData
            }

        // str 8, 16, 32
        case 0xd9...0xdb:
            let lengthSize = 1 << Int(value - 0xd9)
            let length = try unpackInteger(&iterator, size: lengthSize)
            if compatibility {
                let data = try unpackData(&iterator, length: numericCast(length))
                return .Binary(data)
            } else {
                let string = try unpackString(&iterator, length: numericCast(length))
                return .String(string)
            }

        // array 16, 32
        case 0xdc...0xdd:
            let countSize = 1 << Int(value - 0xdb)
            let count = try unpackInteger(&iterator, size: countSize)
            let array = try unpackArray(&iterator, count: numericCast(count), compatibility: compatibility)
            return .Array(array)

        // map 16, 32
        case 0xde...0xdf:
            let countSize = 1 << Int(value - 0xdd)
            let count = try unpackInteger(&iterator, size: countSize)
            let dict = try unpackMap(&iterator, count: numericCast(count), compatibility: compatibility)
            return .Map(dict)

        // negative fixint
        case 0xe0..<0xff:
            return .Int(numericCast(value) - 0x100)

        // negative fixint (workaround for rdar://19779978)
        case 0xff:
            return .Int(numericCast(value) - 0x100)

        default:
            throw MessagePackError.InvalidData
        }
    } else {
        throw MessagePackError.InsufficientData
    }
}

/// Unpacks a data object in the form of `NSData` into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpack(data: Data, compatibility: Bool = false) throws -> MessagePackValue {
    return try unpack(data.makeIterator(), compatibility: compatibility)
}

/// Unpacks a data object in the form of a byte array into a `MessagePackValue`.
///
/// - parameter data: The data to unpack.
///
/// - returns: The contained `MessagePackValue`.
public func unpack<S: Sequence where S.Iterator.Element == Byte>(data: S, compatibility: Bool = false) throws -> MessagePackValue {
    var iterator = data.makeIterator()
    return try unpack(&iterator, compatibility: compatibility)
}
