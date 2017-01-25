import PackageDescription
 
let package = Package(
    name: "MyAwesomeProject",
    dependencies: [
        .Package(
        url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", 
        majorVersion: 2, minor: 0
        ),
        .Package(
        url:"https://github.com/PerfectlySoft/Perfect-MongoDB.git", 
        majorVersion: 2, minor: 0
        ),
        .Package(url:"https://github.com/PerfectlySoft/Perfect-Notifications.git",
         majorVersion: 2, minor: 0
        ),
        .Package(url: "https://github.com/PerfectlySoft/Perfect-Logger.git", 
        majorVersion: 1
        ),
        .Package(url: "https://github.com/hkellaway/Gloss.git", majorVersion: 1, minor: 2)
    ]
)
