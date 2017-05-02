//
//  WebRoutes.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-18.
//
//

import PerfectHTTPServer
import LocalAuthentication

func webRoutes() -> [[String: Any]] {

//	var r: [[String: Any]] = [[String: Any]]()

	var routes = mainAuthenticationRoutes()

	routes.append(["method":"get", "uri":"/**", "handler":PerfectHTTPServer.HTTPHandler.staticFiles,
				   "documentRoot":"./webroot",
				   "allowResponseFilters":true])

	routes.append(["method":"get", "uri":"/", "handler":WebHandlers.home])

	routes.append(["method":"get", "uri":"/tokens", "handler":WebHandlers.tokenList])
	routes.append(["method":"get", "uri":"/tokens/create", "handler":WebHandlers.tokenMod])
	routes.append(["method":"get", "uri":"/tokens/{id}/edit", "handler":WebHandlers.tokenMod])
	routes.append(["method":"post", "uri":"/tokens/create", "handler":WebHandlers.tokenModAction])
	routes.append(["method":"post", "uri":"/tokens/{id}/edit", "handler":WebHandlers.tokenModAction])
	routes.append(["method":"get", "uri":"/tokens/{id}/toggle", "handler":WebHandlers.tokenToggle])
	routes.append(["method":"get", "uri":"/tokens/{id}/delete", "handler":WebHandlers.tokenDelete])

	routes.append(["method":"get", "uri":"/logs", "handler":WebHandlers.logList])
	routes.append(["method":"get", "uri":"/logs/token/all", "handler":WebHandlers.logAllTokens])
	routes.append(["method":"get", "uri":"/logs/token/{token}", "handler":WebHandlers.logToken])
	routes.append(["method":"get", "uri":"/logs/app/{app}", "handler":WebHandlers.logApp])





	routes.append(["method":"get", "uri":"/apps", "handler":WebHandlers.appList])

	routes.append(["method":"post", "uri":"/apps", "handler":WebHandlers.appMod])
	routes.append(["method":"post", "uri":"/apps/{id}/toggle", "handler":WebHandlers.appToggle])

	routes.append(["method":"get", "uri":"/apps/create", "handler":WebHandlers.appMod])
	routes.append(["method":"post", "uri":"/apps/create", "handler":WebHandlers.appModAction])

	routes.append(["method":"get", "uri":"/apps/{id}/edit", "handler":WebHandlers.appMod])
	routes.append(["method":"post", "uri":"/apps/{id}/edit", "handler":WebHandlers.appModAction])

	routes.append(["method":"delete", "uri":"/apps/{id}/delete", "handler":WebHandlers.appDelete])





	routes.append(["method":"get", "uri":"/users", "handler":WebHandlers.userList])

	routes.append(["method":"get", "uri":"/users/create", "handler":WebHandlers.userMod])
	routes.append(["method":"get", "uri":"/users/{id}/edit", "handler":WebHandlers.userMod])

	routes.append(["method":"post", "uri":"/users/create", "handler":WebHandlers.userModAction])
	routes.append(["method":"post", "uri":"/users/{id}/edit", "handler":WebHandlers.userModAction])

	routes.append(["method":"delete", "uri":"/users/{id}/delete", "handler":WebHandlers.userDelete])




	routes.append(["method":"get", "uri":"/graphs", "handler":WebHandlers.graphs])
	routes.append(["method":"get", "uri":"/import", "handler":WebHandlers.importData])
	routes.append(["method":"post", "uri":"/import", "handler":WebHandlers.importDataProcessing])

	routes.append(["method":"get", "uri":"/docs", "handler":WebHandlers.docs])

	return routes
}
