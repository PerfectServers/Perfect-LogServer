//
//  tokens.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-09.
//
//

import PerfectHTTP
import PostgresStORM
import SwiftMoment

extension WebHandlers {

	static func tokenList(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

	//		let tokens = AppToken.listTokens(account: contextAccountID)
			let tokens = AppToken.listTokens()


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"tokenlist?":"true",
				"tokens": tokens
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/index", context: context)
		}
	}

	static func tokenToggle(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
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
	}

	static func tokenMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let app = AppToken()
			var action = "Create"

			if let token = request.urlVariables["id"] {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("token",token))
				try? app.find(findCriteria)

				if app.token.isEmpty {
					redirectRequest(request, response, msg: "Invalid Token", template: "views/tokens")
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
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/tokens", context: context)
		}
	}

	static func tokenModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let app = AppToken()
			var msg = ""

			if let id = request.urlVariables["id"] {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("token",id))
				try? app.find(findCriteria)

				if app.token.isEmpty {
					redirectRequest(request, response, msg: "Invalid Token", template: "views/tokens")
				}
			}


			if let name = request.param(name: "name"), !name.isEmpty {
				app.name = name
				if app.id > 0 {
					try? app.save()
				} else {
					let _ = app.newToken(account: contextAccountID, tokenName: name)
				}

			} else {
				msg = "Please enter the token name."
				redirectRequest(request, response, msg: msg, template: "views/tokens", additional: [
					"tokenmod?":"true",
					])
			}


	//		let tokens = AppToken.listTokens(account: contextAccountID)
			let tokens = AppToken.listTokens()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"tokenslist?":"true",
				"tokens": tokens,
				"msg": msg
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/tokens", context: context)
		}
	}

	/*	===========================================================================
	Delete token functionality
	===========================================================================  */
	static func tokenDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
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
}
