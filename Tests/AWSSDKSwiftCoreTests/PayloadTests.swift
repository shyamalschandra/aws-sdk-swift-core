//
//  PayloadTests.swift
//  AWSSDKSwift
//
//  Created by Adam Fowler 2020/03/01
//
//

import NIO
import XCTest
@testable import AWSSDKSwiftCore

class PayloadTests: XCTestCase {

    func testRequestPayload(_ payload: AWSPayload, expectedResult: String) {
        struct DataPayload: AWSEncodableShape & AWSShapeWithPayload {
            static var payloadPath: String? = "data"
            let data: AWSPayload
            
            private enum CodingKeys: CodingKey {}
        }
        
        do {
            let awsServer = AWSTestServer(serviceProtocol: .json)
            let client = AWSClient(
                accessKeyId: "",
                secretAccessKey: "",
                region: .useast1,
                service:"TestClient",
                serviceProtocol: ServiceProtocol(type: .json, version: ServiceProtocol.Version(major: 1, minor: 1)),
                apiVersion: "2020-01-21",
                endpoint: awsServer.address,
                middlewares: [AWSLoggingMiddleware()],
                eventLoopGroupProvider: .useAWSClientShared
            )
            let input = DataPayload(data: payload)
            let response = client.send(operation: "test", path: "/", httpMethod: "POST", input: input)

            try awsServer.process { request in
                XCTAssertEqual(request.body.getString(at: 0, length: request.body.readableBytes), expectedResult)
                return AWSTestServer.Result(output: .ok, continueProcessing: false)
            }

            try response.wait()
            try awsServer.stop()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDataRequestPayload() {
        testRequestPayload(.data(Data("testDataPayload".utf8)), expectedResult: "testDataPayload")
    }
    
    func testStringRequestPayload() {
        testRequestPayload(.string("testStringPayload"), expectedResult: "testStringPayload")
    }
    
    func testByteBufferRequestPayload() {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: 32)
        byteBuffer.writeString("testByteBufferPayload")
        testRequestPayload(.byteBuffer(byteBuffer), expectedResult: "testByteBufferPayload")
    }
    
    
    static var allTests : [(String, (PayloadTests) -> () throws -> Void)] {
        return [
            ("testStringRequestPayload", testStringRequestPayload),
            ("testDataRequestPayload", testDataRequestPayload),
            ("testByteBufferRequestPayload", testByteBufferRequestPayload),
        ]
    }
}
