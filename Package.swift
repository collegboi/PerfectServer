import PackageDescription
 
let package = Package(
    name: "MyAwesomeProject",
    dependencies: [
        .Package(
            url: "https://github.com/PerfectlySoft/Perfect-Turnstile-MongoDB.git",
                 majorVersion: 0
        ),
        .Package(
            url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git",
            majorVersion: 1, minor: 0
        ),
        .Package(
            url: "https://github.com/hkellaway/Gloss.git",
                 majorVersion: 1, minor: 2
        ),
    ]
)

/*    .Package(
        url: "https://github.com/PerfectlySoft/Perfect-Turnstile-MongoDB.git",
        majorVersion: 1
), .Package(
url: "https://github.com/PerfectlySoft/Perfect-Authentication.git",
majorVersion: 1
),
.Package(url: "https://github.com/iamjono/SwiftString.git", majorVersion: 1, minor: 0),
.Package(url: "https://github.com/iamjono/SwiftRandom.git", majorVersion: 0, minor: 2),
 .Package(
 url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git",
 majorVersion: 2, minor: 1
 ),
 .Package(
 url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git",
 majorVersion: 2, minor: 0
 ),
 .Package(
 url:"https://github.com/PerfectlySoft/Perfect-Notifications.git",
 majorVersion: 2, minor: 0
 ),
 */
