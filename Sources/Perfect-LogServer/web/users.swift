//
//  users.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-08.
//
//


import SwiftMoment
import PerfectHTTP
import PerfectTurnstilePostgreSQL
import TurnstileCrypto
import PerfectLogger

/*
r.add(method: .get, uri: "/apps", handler: WebHandlers.appList)
r.add(method: .get, uri: "/apps/{app}", handler: WebHandlers.appView)
r.add(method: .post, uri: "/apps/{id}/toggle", handler: WebHandlers.appToggle)

*/
extension WebHandlers {

	static func userList(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let users = AuthAccount.listUsers()

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"userlist?":"true",
			"users": users
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "users", context: context)
	}

	static func userMod(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let user = AuthAccount()
		var action = "Create"

		if let id = request.urlVariables["id"] {
			try? user.get(id)

			if user.uniqueID.isEmpty {
				redirectRequest(request, response, msg: "Invalid User", template: "user")
			}

			action = "Edit"
		}


		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"usermod?":"true",
			"action": action,
			"username": user.username,
			"firstname": user.firstname,
			"lastname": user.lastname,
			"email": user.email,
			"uniqueid": user.uniqueID
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "users", context: context)
	}


	static func userModAction(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let user = AuthAccount()
		var msg = ""

		if let id = request.urlVariables["id"] {
			try? user.get(id)

			if user.uniqueID.isEmpty {
				redirectRequest(request, response, msg: "Invalid User", template: "user")
			}
		}


		if let firstname = request.param(name: "firstname"), !firstname.isEmpty,
			let lastname = request.param(name: "lastname"), !lastname.isEmpty,
			let email = request.param(name: "email"), !email.isEmpty,
			let username = request.param(name: "username"), !username.isEmpty{
			user.username = username
			user.firstname = firstname
			user.lastname = lastname
			user.email = email

			if let pwd = request.param(name: "pw"), !pwd.isEmpty {
				user.password = BCrypt.hash(password: pwd)
			}
			
			if user.uniqueID.isEmpty {
				let random: Random = URandom()
				user.id(String(random.secureToken))
				try? user.create()
			} else {
				try? user.save()
			}

		} else {
			msg = "Please enter the use first and last name, as well as a valid email."
			redirectRequest(request, response, msg: msg, template: "users", additional: [
				"usermod?":"true",
				])
		}


		let users = AuthAccount.listUsers()

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"userlist?":"true",
			"users": users,
			"msg": msg
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}

		response.render(template: "users", context: context)
	}



	static func userDelete(request: HTTPRequest, _ response: HTTPResponse) {

//		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated
		if !contextAuthenticated { response.redirect(path: "/login") }

		let user = AuthAccount()

		if let id = request.urlVariables["id"] {
			try? user.get(id)

			// cannot delete yourself
			if user.uniqueID == request.user.authDetails?.account.uniqueID {
				LogFile.debug("You cannot delete yourself.", eventid: "", logFile: debugLogfile)
				redirectRequest(request, response, msg: "You cannot delete yourself.", template: "user")
				return
			}
			let usersCount = AuthAccount()
			try? usersCount.findAll()
			if usersCount.results.cursorData.totalRecords <= 1 {
				LogFile.debug("usersCount.results.cursorData.totalRecords <= 1", eventid: "", logFile: debugLogfile)
				redirectRequest(request, response, msg: "You cannot delete yourself.", template: "user")
				return
			}

			if user.uniqueID.isEmpty {
				LogFile.debug("user.uniqueID.isEmpty Invalid User", eventid: "", logFile: debugLogfile)
				redirectRequest(request, response, msg: "Invalid User", template: "user")
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
