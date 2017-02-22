//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import StORM
import MongoDBStORM
import PerfectTurnstileMongoDB
import PerfectRequestLogger
import TurnstilePerfect


//StORMdebug = true
RequestLogFile.location = "./requests.log"

// Used later in script for the Realm and how the user authenticates.
let pturnstile = TurnstilePerfect()


// Set the connection variables
MongoDBConnection.host = "localhost"
MongoDBConnection.database = "locql"


//Connect the AccessTokenStore
//tokenStore = AccessTokenStore()
//try? tokenStore?.setup()

//let facebook = Facebook(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET")
//let google = Google(clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET")

let server = HTTPServer()

// Register routes and handlers
let authWebRoutes = makeWebAuthRoutes()
let authJSONRoutes = makeJSONAuthRoutes("/api/v1")

// Add the routes to the server.
server.addRoutes(authWebRoutes)
server.addRoutes(authJSONRoutes)

server.addRoutes(makeRoutes())
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

// Setup logging
let myLogger = RequestLogger()


// add routes to be excluded from auth check
var authenticationConfig = AuthenticationConfig()
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/register")
// add routes to be checked for auth
authenticationConfig.include("/api/v1/count")
authenticationConfig.include("/api/v1/get/all")
authenticationConfig.include("/api/v1/update")
authenticationConfig.include("/api/v1/delete")


let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])

server.setRequestFilters([(authFilter, .high)])

server.setRequestFilters([(myLogger, .high)])
server.setResponseFilters([(myLogger, .low)])

// Set a listen port of 8181
server.serverPort = 8181
//server.serverAddress = "localhost"

// Where to serve static files from
server.documentRoot = "./webroot"
//server.serverAddress = "127.0.0.1"./

//EmailController.sendEmail()

FileController.setup()
RemoteConfig.setup()

//NotficationController.sendSingleNotfication(deviceID: "e4d8fbbe085dfa93e5212a3759a774bed6264b17a437ad94b51359c92105ab3a")

do {
    // Launch the servers based on the configuration data.
    try server.start()
} catch {
    fatalError("\(error)") // fatal error launching one of the servers
}

