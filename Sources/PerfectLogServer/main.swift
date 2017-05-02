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
import PerfectHTTP
import PerfectHTTPServer
import PerfectRequestLogger
import PerfectSession
import PerfectSessionPostgreSQL
import LocalAuthentication

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

//let pturnstile = TurnstilePerfectRealm()
let apiRoute = "/api/v1/"

var baseURL = ""
var domain = "localhost"
// set up creds
makeCreds()

#if os(Linux)
let fname = "./config/ApplicationConfigurationLinux.json"
#else
let fname = "./config/ApplicationConfiguration.json"
#endif
let opts = initializeSchema(fname)
let additionalOpts = additionalInitializeSchema(fname)

//print(additionalOpts)

// Configuration of Session
SessionConfig.name = "LogServer"
SessionConfig.idle = 86400
SessionConfig.cookieDomain = additionalOpts["domain"] as? String ?? domain
SessionConfig.IPAddressLock = false
SessionConfig.userAgentLock = false
SessionConfig.CSRF.checkState = true
SessionConfig.CORS.enabled = true
SessionConfig.cookieSameSite = .lax

//print(SessionConfig.cookieDomain)

RequestLogFile.location = "./log.log"


let sessionDriver = SessionPostgresDriver()


// setup tables
setup()

//StORMdebug = true


// add routes to be checked for auth
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("/*")
authenticationConfig.exclude(["/register", "/verifyAccount/*", "/registrationCompletion", "/check"])
authenticationConfig.exclude("/login")
authenticationConfig.exclude("/api/v1/log/*")
authenticationConfig.exclude("/api/v1/session")
authenticationConfig.exclude("/api/v1/login")
authenticationConfig.exclude("/api/v1/logout")
authenticationConfig.exclude(["/", "/assets/*", "/fonts/*", "/images/*"])


AuthFilter.authenticationConfig = authenticationConfig



var confData = [
	"servers": [
		[
			"name":"localhost",
			"port":httpPort,
			"routes":[],
			"filters":[
				[
					"type":"response",
					"priority":"high",
					"name":PerfectHTTPServer.HTTPFilter.contentCompression,
					],
				[
					"type":"request",
					"priority":"low",
					"name":AuthFilter.filter,
					],
				[
					"type":"request",
					"priority":"high",
					"name":SessionPostgresFilter.filterAPIRequest,
					],
				[
					"type":"request",
					"priority":"high",
					"name":RequestLogger.filterAPIRequest,
					],
				[
					"type":"response",
					"priority":"high",
					"name":SessionPostgresFilter.filterAPIResponse,
					],
				[
					"type":"response",
					"priority":"high",
					"name":RequestLogger.filterAPIResponse,
					]
			]
		]
	]
]


// Add routes
confData["servers"]?[0]["routes"] = webRoutes() + apiRoutes()

do {
	// Launch the servers based on the configuration data.
	try HTTPServer.launch(configurationData: confData)
} catch {
	fatalError("\(error)") // fatal error launching one of the servers
}
