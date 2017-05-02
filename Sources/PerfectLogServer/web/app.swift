//
//  app.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import SwiftMoment
import PerfectHTTP


/*
r.add(method: .get, uri: "/apps", handler: WebHandlers.appList)
r.add(method: .get, uri: "/apps/{app}", handler: WebHandlers.appView)
r.add(method: .post, uri: "/apps/{id}/toggle", handler: WebHandlers.appToggle)

*/
extension WebHandlers {

	static func appList(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

	//		let apps = Application.listApps(account: contextAccountID)
			let apps = Application.listApps()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"applist?":"true",
				"apps": apps
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/index", context: context)
		}
	}


	static func appView(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
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
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/index", context: context)
		}
	}

	static func appToggle(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let t = Application()
			let id = request.urlVariables["id"] ?? ""
			do {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("accountid",contextAccountID))
				findCriteria.append(("appuuid",id))

				try t.find(findCriteria)

				if t.valid == true { t.valid = false } else { t.valid = true }
				try t.save()
			} catch {
				print("Toggling token id \(id) error - cannot load: \(error)")
			}

			_ = try? response.setBody(json: ["action":"complete"])
			response.completed()
		}

	}



	static func appMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let app = Application()
			var action = "Create"

			if let appuuid = request.urlVariables["id"] {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("appuuid",appuuid))
				try? app.find(findCriteria)

				if app.appuuid.isEmpty {
					redirectRequest(request, response, msg: "Invalid App", template: "views/apps")
				}

				action = "Edit"
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"appmod?":"true",
				"action": action,
				"appuuid": app.appuuid,
				"name": app.name
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/apps", context: context)
		}
	}

	static func appModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let app = Application()
			var msg = ""

			if let id = request.urlVariables["id"] {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("appuuid",id))
				try? app.find(findCriteria)

				if app.appuuid.isEmpty {
					redirectRequest(request, response, msg: "Invalid Application", template: "views/apps")
				}
			}


			if let name = request.param(name: "name"), !name.isEmpty {
				app.name = name

				if app.id > 0 {
					try? app.save()
				} else {
					let _ = app.newApplication(account: contextAccountID, appName: name)
				}


			} else {
				msg = "Please enter the application name."
				redirectRequest(request, response, msg: msg, template: "views/apps", additional: [
					"appmod?":"true",
					])
			}


	//		let apps = Application.listApps(account: contextAccountID)
			let apps = Application.listApps()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"appslist?":"true",
				"apps": apps,
				"msg": msg
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/apps", context: context)
		}
	}

	/*	===========================================================================
		Delete application functionality
	===========================================================================  */
	static func appDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let obj = Application()

			if let id = request.urlVariables["id"] {
				var findCriteria = [(String,Any)]()
				findCriteria.append(("appuuid",id))
				try? obj.find(findCriteria)

				if obj.appuuid.isEmpty {
					badRequest(request, response, msg: "Invalid Application")
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
