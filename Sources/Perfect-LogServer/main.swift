//
//  main.swift
//  Perfect Log Server
//
//  Created by Jonathan Guthrie on 2016-11-182.
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

import StORM
import PostgresStORM
import PerfectTurnstilePostgreSQL
import TurnstilePerfect

import PerfectHTTP
import PerfectHTTPServer

import JSONConfig
import PerfectRequestLogger

let debugLogfile = "./debug.log"
let webRoot = "./webroot"
RequestLogFile.location = "./webLog.log"
#if os(Linux)
	let fileRoot = "/perfect-deployed/perfect-logserver/"
	var httpPort = 8100
#else
	let fileRoot = ""
	var httpPort = 8181
#endif

let pturnstile = TurnstilePerfectRealm()
let apiRoute = "/api/v1/"

// set up creds
makeCreds()

// setup tables
setup()

//StORMdebug = true

// Create HTTP server.
let server = HTTPServer()
server.addRoutes(makeWebAuthRoutes())
server.addRoutes(apiRoutes())
server.addRoutes(webRoutes())

// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
//authenticationConfig.include("/api/v1/check")
authenticationConfig.include("/admin/*")
authenticationConfig.exclude("/admin/login")
authenticationConfig.exclude("/admin/register")
authenticationConfig.exclude("/api/v1/graph")


let authFilter = AuthFilter(authenticationConfig)

// Note that order matters when the filters are of the same priority level
server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])
server.setRequestFilters([(authFilter, .high)])



// Setup logging
let logger = RequestLogger()
// Set the log marker for the timer when the request is incoming
server.setRequestFilters([(logger, .high)])
// Finish the log trracking when the request is complete and ready to be returned to client
server.setResponseFilters([(logger, .low)])

server.serverPort = UInt16(httpPort)
server.documentRoot = webRoot

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
