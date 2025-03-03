//
//  DecodingNumbersTests.swift
//  DecodingNumbersTests
//
//  Created by Markos Zoulias Charatzas on 03/03/2025.
//

import Foundation
import Testing

public enum RawValue: Codable, Equatable, CustomDebugStringConvertible {
    
    public static func == (lhs: RawValue, rhs: RawValue) -> Bool {
        switch (lhs, rhs) {
        case (.int(let l), .int(let r)):
            return l == r
        case (.double(let l), .double(let r)):
            return l == r
        case (.array(let l), .array(let r)):
            return l == r
        case (.dictionary(let l), .dictionary(let r)):
            return l == r
        default:
            return false
        }
    }
    
    case int(Int)
    case double(Double)
    case array([RawValue])
    case dictionary([String: RawValue])
    
    public var debugDescription : String {
        switch self {
        case .int(let value):
            return "\(value)"
        case .double(let value):
            return "\(value)"
        case .array(let value):
            return "[\(value.map(\.debugDescription).joined(separator: ", "))]"
        case .dictionary(let value):
            return "[\(value.map(\.key).joined(separator: ", ")): \(value.map(\.value).map(\.debugDescription).joined(separator: ", "))]"
        }
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode([RawValue].self) {
            self = .array(value)
        } else if let value = try? container.decode([String: RawValue].self) {
            self = .dictionary(value)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .dictionary(let value):
            try container.encode(value)
        }
    }
}

struct Value: Codable, Equatable, CustomDebugStringConvertible {
    
    public static func == (lhs: Value, rhs: Value) -> Bool {
        return lhs.raw == rhs.raw
    }
    
    let raw: RawValue
    
    var debugDescription: String {
        raw.debugDescription
    }
    
    init(_ raw: RawValue) {
        self.raw = raw
    }
    
    init(from decoder: any Decoder) throws {
        self.raw = try RawValue(from: decoder)
    }
    
    func encode(to encoder: any Encoder) throws {
        try self.raw.encode(to: encoder)
    }
}

struct DecodingNumbersTests {

    @Test func int() async throws {

        let int: Int = 42

        let json = """
        {
            "int": \(int)
        }
        """
        let decoder = JSONDecoder()
        
        let data = try #require(json.data(using: .utf8))
        let value = try decoder.decode(Value.self, from: data)

        switch value.raw {
        case .int(let value):
            #expect(value == int)
        default:
            return
        }
    }

    @Test func double() async throws {

        let double: Double = 3.14

        let json = """
        {
            "double": \(double)
        }
        """
        let decoder = JSONDecoder()

        let data = try #require(json.data(using: .utf8))
        let value = try decoder.decode(Value.self, from: data)

        switch value.raw {
        case .double(let value):
            #expect(value == double)
        default:
            return
        }
    }
    
    @Test func both() async throws {

        let int: Int = 42
        let double: Double = 3.14

        let json = """
        {
            "int": \(int),
            "double": \(double)
        }
        """
        let decoder = JSONDecoder()
        
        let data = try #require(json.data(using: .utf8))
        let actual = try decoder.decode(Value.self, from: data)

        let value: RawValue = .dictionary(["int": .int(int), "double": .double(double)])
        let expected = Value(value)
        
        #expect(actual == expected)
    }

    @Test func doubleRepresentableAsInt() async throws {

        let int: Int = 42
        let double: Double = 42.0

        let json = """
        {
            "int": \(int),
            "double": \(double)
        }
        """
        let decoder = JSONDecoder()
        
        let data = try #require(json.data(using: .utf8))
        let actual = try decoder.decode(Value.self, from: data)

        let value: RawValue = .dictionary(["int": .int(int), "double": .double(double)])
        let expected = Value(value)
        
        #expect(actual == expected)
    }
}
