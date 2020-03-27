//
//  Payload.swift
//  AWSSDKCore
//
//  Created by Adam Fowler on 2020/03/01.
//
import struct Foundation.Data
import NIO
import NIOFoundationCompat

/// Object storing request/response payload
public struct AWSPayload {
    
    /// Construct a payload from a ByteBuffer
    public static func byteBuffer(_ byteBuffer: ByteBuffer) -> Self {
        return Self(byteBuffer: byteBuffer)
    }
    
    /// Construct a payload from a Data
    public static func data(_ data: Data) -> Self {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: data.count)
        byteBuffer.writeBytes(data)
        return Self(byteBuffer: byteBuffer)
    }
    
    /// Construct a payload from a String
    public static func string(_ string: String) -> Self {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: string.utf8.count)
        byteBuffer.writeString(string)
        return Self(byteBuffer: byteBuffer)
    }

    /// return payload as Data
    public func asData() -> Data? {
        return byteBuffer.getData(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes, byteTransferStrategy: .noCopy)
    }
    
    /// return payload as String
    public func asString() -> String? {
        return byteBuffer.getString(at: byteBuffer.readerIndex, length: byteBuffer.readableBytes, encoding: .utf8)
    }
    
    /// return payload as ByteBuffer
    public func asBytebuffer() -> ByteBuffer {
        return byteBuffer
    }
    
    let byteBuffer: ByteBuffer
}

// The decode/encode functions are here temporarily until we merge in https://github.com/swift-aws/aws-sdk-swift-core/pull/214. After that we
// should be able to remove them
extension AWSPayload: Codable {
    
    // AWSPayload has to comform to Codable so I can add it to AWSShape objects (which conform to Codable). But we don't want the
    // Encoder/Decoder ever to process a AWSPayload
    public init(from decoder: Decoder) throws {
        preconditionFailure("Cannot decode an AWSPayload")
    }
    
    public func encode(to encoder: Encoder) throws {
        preconditionFailure("Cannot encode an AWSPayload")
    }
}
