
import PerfectLib

import StORM
import PostgresStORM

import PerfectHTTP
import PerfectHTTPServer

import JSONConfig
import PerfectRequestLogger


#if os(Linux)
	let fileRoot = "/perfect-deployed/perfect-logserver/"
	let webRoot = "./webroot"
	var httpPort = 8100
#else
	let fileRoot = ""
	let webRoot = "./webroot"
	var httpPort = 8181
#endif


let apiRoute = "/api/v1/"

// set up creds
makeCreds()

// db Setup

// Create HTTP server.
let server = HTTPServer()
server.addRoutes(apiRoutes())

//// Setup logging
let httplogger = RequestLogger()

server.setRequestFilters([(httplogger, .high)])
server.setResponseFilters([(httplogger, .low)])

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
