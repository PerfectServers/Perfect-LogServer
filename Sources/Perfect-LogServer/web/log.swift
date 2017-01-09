//
//  log.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import SwiftMoment
import PerfectHTTP

/*
r.add(method: .get, uri: "/logs", handler: WebHandlers.logList)
r.add(method: .get, uri: "/logs/token/all", handler: WebHandlers.logAllTokens)
r.add(method: .get, uri: "/logs/token/{token}", handler: WebHandlers.logToken)
r.add(method: .get, uri: "/logs/app/{app}", handler: WebHandlers.logApp)

*/
extension WebHandlers {

	static func badRequest(_ request: HTTPRequest, _ response: HTTPResponse, msg: String) {
		response.status = .badRequest
		var resp = [String: Any]()
		resp["error"] = msg
		do {
			try response.setBody(json: resp)
		} catch {
			print("error setBody: \(error)")
		}
		response.completed()
		return
	}

	
	static func logList(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let sessionid = request.user.authDetails?.sessionID ?? ""

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"loglist?":"true",
//			"token":token,
			"sessionid":sessionid
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "index", context: context)
	}

	static func logAllTokens(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let t = AppToken()
		var findCriteria = [(String,Any)]()
		findCriteria.append(("accountid",contextAccountID))
		try? t.find(findCriteria)

		var tokens = [[String: Any]]()

		for row in t.rows() {
			var r = [String: Any]()
			r["token"] = row.token
			r["accountid"] = row.accountid
			r["dategenerated"] = moment(row.dategenerated * 1000)
			if row.valid {
				r["valid"] = "Valid"
			} else {
				r["valid"] = "Expired"
			}
			tokens.append(r)
		}



		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenlist?":"true",
			"tokens": tokens
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "index", context: context)
	}




	static func logToken(request: HTTPRequest, _ response: HTTPResponse) {


		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let sessionid = request.user.authDetails?.sessionID ?? ""

		guard let token = request.urlVariables["token"] else {
			WebHandlers.badRequest(request, response, msg: "No token")
			return
		}

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"loglist?":"true",
			"token":token,
			"sessionid":sessionid
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "index", context: context)

	}

	static func logApp(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let t = AppToken()
		var findCriteria = [(String,Any)]()
		findCriteria.append(("accountid",contextAccountID))
		try? t.find(findCriteria)

		var tokens = [[String: Any]]()

		for row in t.rows() {
			var r = [String: Any]()
			r["token"] = row.token
			r["accountid"] = row.accountid
			r["dategenerated"] = moment(row.dategenerated * 1000)
			if row.valid {
				r["valid"] = "Valid"
			} else {
				r["valid"] = "Expired"
			}
			tokens.append(r)
		}



		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenlist?":"true",
			"tokens": tokens
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "index", context: context)
	}

	

}
