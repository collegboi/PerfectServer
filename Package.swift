// Generated automatically by Perfect Assistant Application
// Date: 2017-01-12 20:32:37 +0000

import PackageDescription
 
let package = Package(
    name: "MyAwesomeProject",
    targets: [],
    dependencies: [
        .Package( url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", majorVersion: 2, minor: 0),
        .Package( url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git", majorVersion: 2, minor: 0 ),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git", majorVersion: 2, minor: 0),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git",  majorVersion: 1)
    ]
)
