//
//  APIRoutes.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-11.
//
//

import PerfectHTTP

func apiRoutes() -> Routes {
	var r = Routes()

	r.add(method: .get, uri: "/check", handler: checkme)

	r.add(method: .post, uri: "/api/v1/log/{token}", handler: logLog)

	// retrieves a log
	r.add(method: .get, uri: "/api/v1/get/log/{token}", handler: logGetLog)
	r.add(method: .post, uri: "/api/v1/get/log", handler: logGetLog)


	r.add(method: .post, uri: "/api/v1/graph", handler: GraphDataProcess.logGetGraphData)
	r.add(method: .post, uri: "/api/v1/graph/save", handler: GraphDataProcess.logSaveGraphData)
	r.add(method: .get, uri: "/api/v1/graph/load/{id}", handler: GraphDataProcess.logLoadGraphData)

	return r
}




// Generic "Check" function for health check.
func checkme(request: HTTPRequest, _ response: HTTPResponse) {
	response.setHeader(.contentType, value: "application/json")
	do {
		try response.setBody(json: ["ok":"ok"])
	} catch {
		print(error)
	}
	response.completed()
}

