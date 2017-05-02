//
//  users.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-08.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectLogger
import LocalAuthentication


extension WebHandlers {

	static func userList(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let users = Account.listUsers()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"users": users
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/users", context: context)
		}
	}
	static func userMod(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			var action = "Create"

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid User", template: "views/user")
				}

				action = "Edit"
			}


			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"usermod?":"true",
				"action": action,
				"username": user.username,
				"firstname": user.detail["firstname"] ?? "",
				"lastname": user.detail["lastname"] ?? "",
				"email": user.email,
				"uniqueid": user.id
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/users", context: context)
		}
	}

	static func userModAction(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAccountID = request.session?.userid ?? ""
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()
			var msg = ""

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				if user.id.isEmpty {
					redirectRequest(request, response, msg: "Invalid User", template: "views/user")
				}
			}


			if let firstname = request.param(name: "firstname"), !firstname.isEmpty,
				let lastname = request.param(name: "lastname"), !lastname.isEmpty,
				let email = request.param(name: "email"), !email.isEmpty,
				let username = request.param(name: "username"), !username.isEmpty{
				user.username = username
				user.detail["firstname"] = firstname
				user.detail["lastname"] = lastname
				user.email = email


				if let pwd = request.param(name: "pw"), !pwd.isEmpty {
					user.makePassword(pwd)
				}

				if user.id.isEmpty {
					user.makeID()
					try? user.create()
				} else {
					try? user.save()
				}

			} else {
				msg = "Please enter the use first and last name, as well as a valid email."
				redirectRequest(request, response, msg: msg, template: "views/users", additional: [
					"usermod?":"true",
					])
			}


			let users = Account.listUsers()

			var context: [String : Any] = [
				"accountID": contextAccountID,
				"authenticated": contextAuthenticated,
				"userlist?":"true",
				"users": users,
				"msg": msg
			]
			if contextAuthenticated {
				for i in WebHandlers.extras(request) {
					context[i.0] = i.1
				}
			}

			response.render(template: "views/users", context: context)
		}
	}


	static func userDelete(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated { response.redirect(path: "/login") }

			let user = Account()

			if let id = request.urlVariables["id"] {
				try? user.get(id)

				// cannot delete yourself
				if user.id == (request.session?.userid ?? "") {
					LogFile.debug("You cannot delete yourself.", eventid: "", logFile: debugLogfile)
					redirectRequest(request, response, msg: "You cannot delete yourself.", template: "views/user")
					return
				}
				let usersCount = Account()
				try? usersCount.findAll()
				if usersCount.results.cursorData.totalRecords <= 1 {
					LogFile.debug("usersCount.results.cursorData.totalRecords <= 1", eventid: "", logFile: debugLogfile)
					redirectRequest(request, response, msg: "You cannot delete yourself.", template: "views/user")
					return
				}

				if user.id.isEmpty {
					LogFile.debug("user.uniqueID.isEmpty Invalid User", eventid: "", logFile: debugLogfile)
					redirectRequest(request, response, msg: "Invalid User", template: "views/user")
				} else {
					try? user.delete()
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
