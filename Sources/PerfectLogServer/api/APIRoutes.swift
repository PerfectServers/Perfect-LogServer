//
//  APIRoutes.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-11.
//
//

import PerfectHTTPServer
import PerfectHTTP

func apiRoutes() -> [[String: Any]] {
	var routes: [[String: Any]] = [[String: Any]]()

	routes.append(["method":"get", "uri":"/check", "handler":APIRoutes.checkme])
	routes.append(["method":"post", "uri":"/api/v1/log/{token}", "handler":APIRoutes.logLog])

	routes.append(["method":"get", "uri":"/api/v1/get/log/{token}", "handler":APIRoutes.logGetLog])
	routes.append(["method":"post", "uri":"/api/v1/get/log", "handler":APIRoutes.logGetLog])

	routes.append(["method":"post", "uri":"/api/v1/graph", "handler":GraphDataProcess.logGetGraphData])
	routes.append(["method":"post", "uri":"/api/v1/graph/save", "handler":GraphDataProcess.logSaveGraphData])
	routes.append(["method":"get", "uri":"/api/v1/graph/load/{id}", "handler":GraphDataProcess.logLoadGraphData])

	return routes
}



public class APIRoutes {

	public static func checkme(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			_ = try? response.setBody(json: ["ok":"ok"])
			response.completed()
		}
	}
}
