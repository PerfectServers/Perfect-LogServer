//
//  WebRoutes.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-18.
//
//

import PerfectHTTP
import PerfectTurnstilePostgreSQL

func webRoutes() -> Routes {
	var r = Routes()

	r.add(method: .get, uri: "/", handler: WebHandlers.home)
	r.add(method: .get, uri: "/login", handler: WebHandlers.home)
	r.add(method: .get, uri: "/logout", handler: AuthHandlersWeb.logoutHandler)

	// disable if registration restrictions desired.
	r.add(method: .get, uri: "/register", handler: WebHandlers.home)

	r.add(method: .get, uri: "/tokens", handler: WebHandlers.tokenList)
	// TODO: Restructure to avoid GET requests for action-inducing URL's
	r.add(method: .get, uris: ["/tokens/create", "/tokens/{id}/edit"], handler: WebHandlers.tokenMod)
	r.add(method: .post, uris: ["/tokens/create", "/tokens/{id}/edit"], handler: WebHandlers.tokenModAction)
	r.add(method: .get, uri: "/tokens/{id}/toggle", handler: WebHandlers.tokenToggle)
	r.add(method: .delete, uri: "/tokens/{id}/delete", handler: WebHandlers.tokenDelete)

	r.add(method: .get, uri: "/logs", handler: WebHandlers.logList)
	r.add(method: .get, uri: "/logs/token/all", handler: WebHandlers.logAllTokens)
	r.add(method: .get, uri: "/logs/token/{token}", handler: WebHandlers.logToken)
	r.add(method: .get, uri: "/logs/app/{app}", handler: WebHandlers.logApp)

	r.add(method: .get, uri: "/apps", handler: WebHandlers.appList)
	r.add(method: .post, uri: "/apps", handler: WebHandlers.appMod)
	r.add(method: .post, uri: "/apps/{id}/toggle", handler: WebHandlers.appToggle)
	r.add(method: .get, uris: ["/apps/create", "/apps/{id}/edit"], handler: WebHandlers.appMod)
	r.add(method: .post, uris: ["/apps/create", "/apps/{id}/edit"], handler: WebHandlers.appModAction)
	r.add(method: .delete, uri: "/apps/{id}/delete", handler: WebHandlers.appDelete)

	r.add(method: .get, uri: "/users", handler: WebHandlers.userList)
	r.add(method: .get, uris: ["/users/create", "/users/{id}/edit"], handler: WebHandlers.userMod)
	r.add(method: .post, uris: ["/users/create", "/users/{id}/edit"], handler: WebHandlers.userModAction)
	r.add(method: .delete, uri: "/users/{id}/delete", handler: WebHandlers.userDelete)
	///users/qPStyRuhvw55aVajR5t6Xg/delete

	r.add(method: .get, uri: "/graphs", handler: WebHandlers.graphs)
	r.add(method: .get, uri: "/import", handler: WebHandlers.importData)
	r.add(method: .post, uri: "/import", handler: WebHandlers.importDataProcessing)


	r.add(method: .get, uri: "/docs", handler: WebHandlers.docs)
	return r
}
