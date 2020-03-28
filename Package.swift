// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "AWSSDKSwiftCore",
    products: [
        .library(name: "AWSSDKSwiftCore", targets: ["AWSSDKSwiftCore"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .upToNextMajor(from:"2.13.1")),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", .upToNextMajor(from:"2.4.1")),
        .package(url: "https://github.com/adam-fowler/swift-nio-transport-services.git", .branch("master")),
        .package(url: "https://github.com/adam-fowler/async-http-client.git", .branch("niots"))
    ],
    targets: [
        .target(
            name: "AWSSDKSwiftCore",
            dependencies: [
                "AsyncHTTPClient",
                "AWSSignerV4",
                "NIO",
                "NIOHTTP1",
                "NIOSSL",
                "NIOTransportServices",
                "NIOFoundationCompat",
                "INIParser"
            ]),
        .target(name: "AWSSignerV4", dependencies: ["AWSCrypto", "NIOHTTP1"]),
        .target(name: "INIParser", dependencies: []),
        .target(name: "AWSCrypto", dependencies: []),

        .testTarget(name: "AWSCryptoTests", dependencies: ["AWSCrypto"]),
        .testTarget(name: "AWSSDKSwiftCoreTests", dependencies: ["AWSSDKSwiftCore", "NIOTestUtils"]),
        .testTarget(name: "AWSSignerTests", dependencies: ["AWSSignerV4"])
    ]
)

// switch for whether to use swift crypto. Swift crypto requires macOS10.15 or iOS13.I'd rather not pass this requirement on
#if os(Linux)
let useSwiftCrypto = true
#else
let useSwiftCrypto = false
#endif

// Use Swift cypto on Linux.
if useSwiftCrypto {
    package.dependencies.append(.package(url: "https://github.com/apple/swift-crypto.git", from: "1.0.0"))
    package.targets.first{$0.name == "AWSCrypto"}?.dependencies.append("Crypto")
}
