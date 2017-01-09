//
//  tokens.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-09.
//
//

import PerfectHTTP
import PostgresStORM
import TurnstilePerfect
import SwiftMoment

extension WebHandlers {

	static func tokenList(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let tokens = AppToken.listTokens(account: contextAccountID)


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

//	static func tokenAdd(request: HTTPRequest, _ response: HTTPResponse) {
//
//		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
//		let contextAuthenticated = request.user.authenticated
//		if !contextAuthenticated { response.redirect(path: "/login") }
//
//		let t = AppToken()
//		let _ = t.newToken(account: contextAccountID, tokenName: "")
//		response.redirect(path: "/tokens")
//	}

	static func tokenToggle(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let t = AppToken()
		let id = request.urlVariables["id"] ?? ""
		do {
			var findCriteria = [(String,Any)]()
			findCriteria.append(("accountid",contextAccountID))
			findCriteria.append(("token",id))

			try t.find(findCriteria)

			if t.valid == true { t.valid = false } else { t.valid = true }
			try t.save()
		} catch {
			print("Toggling token id \(id) error - cannot load: \(error)")
		}

		response.redirect(path: "/tokens")
	}
	
	static func tokenMod(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let app = AppToken()
		var action = "Create"

		if let token = request.urlVariables["id"] {
			var findCriteria = [(String,Any)]()
			findCriteria.append(("token",token))
			try? app.find(findCriteria)

			if app.token.isEmpty {
				redirectRequest(request, response, msg: "Invalid Token", template: "tokens")
			}

			action = "Edit"
		}


		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenmod?":"true",
			"action": action,
			"token": app.token,
			"name": app.name
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "tokens", context: context)
	}


	static func tokenModAction(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let app = AppToken()
		var msg = ""

		if let id = request.urlVariables["token"] {
			var findCriteria = [(String,Any)]()
			findCriteria.append(("token",id))
			try? app.find(findCriteria)

			if app.token.isEmpty {
				redirectRequest(request, response, msg: "Invalid Token", template: "tokens")
			}
		}


		if let name = request.param(name: "name"), !name.isEmpty {
			app.name = name

			let _ = app.newToken(account: contextAccountID, tokenName: name)


		} else {
			msg = "Please enter the token name."
			redirectRequest(request, response, msg: msg, template: "tokens", additional: [
				"tokenmod?":"true",
				])
		}


		let tokens = AppToken.listTokens(account: contextAccountID)

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenslist?":"true",
			"tokens": tokens,
			"msg": msg
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "tokens", context: context)
	}
	
	/*	===========================================================================
	Delete token functionality
	===========================================================================  */
	static func tokenDelete(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let obj = AppToken()

		if let id = request.urlVariables["id"] {
			var findCriteria = [(String,Any)]()
			findCriteria.append(("token",id))
			try? obj.find(findCriteria)

			if obj.token.isEmpty {
				badRequest(request, response, msg: "Invalid Token")
			} else {
				try? obj.delete()
			}
		}


		response.setHeader(.contentType, value: "application/json")
		var resp = [String: Any]()
		resp["error"] = "None"
		do {
			try response.setBody(json: resp)
		} catch {
			print("error setBody: \(error)")
		}
		response.completed()
		return
	}
}
