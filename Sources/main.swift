//
//  main.swift
//  MyAwesomeProject
//
//
//===----------------------------------------------------------------------===//
//
//===----------------------------------------------------------------------===//
//

import Foundation

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import MongoDBStORM
import PerfectTurnstileMongoDB
import PerfectRequestLogger
import TurnstilePerfect

import SwiftCron

//StORMdebug = true
RequestLogFile.location = "./requests.log"

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfect()


// Set the connection variables
MongoDBConnection.host = "localhost"
MongoDBConnection.database = "locql"

let server = HTTPServer()

// Register routes and handlers
//let authWebRoutes = makeWebAuthRoutes()
//let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
//server.addRoutes(authWebRoutes)
//server.addRoutes(authJSONRoutes)

//server.addRoutes(mainHandler())

//server.addRoutes(makeRoutes())
server.addRoutes(makeDatabaseRoutes())
server.addRoutes(makeRCRoutes())
server.addRoutes(makeTrackerRoutes())
server.addRoutes(makeTranslationRoutes())
server.addRoutes(makeNotificationRoutes())
server.addRoutes(makeFileUploadRoutes())
server.addRoutes(makeSystemRoutes())
server.addRoutes(makeLoginRoutes())
server.addRoutes(makeBackupRoutes())
server.addRoutes(makeLogsRoutes())
server.addRoutes(makeConfigSettingRoutes())

// Setup logging
let myLogger = RequestLogger()


let headerFilter = HeaderFilter()

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(headerFilter, .high)])

server.setRequestFilters([(myLogger, .high)])
server.setResponseFilters([(myLogger, .low)])

// Set a listen port of 8181
server.serverPort = 8181

// Where to serve static files from
server.documentRoot = "./webroot"

//server.serverAddress = "127.0.0.1"
//server.serverAddress = "localhost"

//EmailController.sendEmail()

FileController.setup()
RemoteConfig.setup()
//JobController.setup()

do {
    // Launch the servers based on the configuration data.
    try server.start()
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}


// add routes to be excluded from auth check
//var authenticationConfig = AuthenticationConfig()
//authenticationConfig.exclude("/api/v1/login")
//authenticationConfig.exclude("/api/v1/register")
//// add routes to be checked for auth
//authenticationConfig.include("/api/v1/count")
//authenticationConfig.include("/api/v1/get/all")
//authenticationConfig.include("/api/v1/update")
//authenticationConfig.include("/api/v1/delete")

//authenticationConfig.include("/api/")

//let authFilter = AuthFilter(authenticationConfig)
//NotficationController.sendSingleNotfication(deviceID: "e4d8fbbe085dfa93e5212a3759a774bed6264b17a437ad94b51359c92105ab3a")
