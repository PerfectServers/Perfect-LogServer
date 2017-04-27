//
//  WebHandlers.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-18.
//
//

import PerfectHTTP
import PostgresStORM
import TurnstilePerfect
import SwiftMoment
import Foundation

class WebHandlers {

	static func extras() -> [String : Any] {
		let logObj	= LogData()

		return [
			"tokensLeft": logObj.distinctTokens(10),
			"appsLeft": logObj.distinctApps(10)
		]

	}

	static func redirectRequest(_ request: HTTPRequest, _ response: HTTPResponse, msg: String, template: String, additional: [String:String] = [String:String]()) {
		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"msg": msg
			]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		for i in additional {
			context[i.0] = i.1
		}


		response.render(template: template, context: context)
		response.completed()
		return
	}


	static func home(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		response.render(template: "index", context: context)
	}
	
	
	static func docs(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		response.render(template: "docs", context: context)
	}
	
	

	static func graphs(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

		let tokens = AppToken.listTokens()
		let graphs = GraphSave.listGraphs()

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenlist": tokens,
			"graphconfigs": graphs,
			"token": request.user.authDetails?.sessionID ?? ""
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		response.render(template: "graphs", context: context)
	}
	
	
	static func importData(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

//		let tokens = AppToken.listTokens(account: contextAccountID)
		let tokens = AppToken.listTokens()
//		let apps = Application.listApps(account: contextAccountID)
		let apps = Application.listApps()

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenlist": tokens,
			"applist": apps,
			"token": request.user.authDetails?.sessionID ?? ""
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		response.render(template: "import", context: context)
	}
	
	
	static func importDataProcessing(request: HTTPRequest, _ response: HTTPResponse) {

		let contextAccountID = request.user.authDetails?.account.uniqueID ?? ""
		let contextAuthenticated = request.user.authenticated

		if let token = request.param(name: "gettoken"),
			let loglevel = request.param(name: "getloglevel") {

			let this = LogData()

			this.token = token

			if let appuuid = request.param(name: "getapp") {
				this.appuuid = appuuid
			}
//			if let eventid = incoming["eventid"] {
//				this.eventid = eventid as? String ?? ""
//			}

			this.loglevel = this.logLevelFromString(loglevel)

//			if let detail = incoming["detail"] {
//				this.detail = detail as? [String:Any] ?? [String:Any]()
//			}


			// ===================== EXCLUSIONS =====================
			let excl1 = request.param(name: "param1_i")?.split(",")
			let excl2 = request.param(name: "param2_i")?.split(",")
			let excl3 = request.param(name: "param3_i")?.split(",")
			// ===================== EXCLUSIONS =====================



			if let dd = request.param(name: "importdata") {
				do {
					let data = dd.split("\r\n")
					try data.forEach{
						line in
						let lineData = line.split(",")
						let thisLine = LogData()
						thisLine.token = this.token
						thisLine.loglevel = this.loglevel
						thisLine.appuuid = this.appuuid

						let formatter = DateFormatter()
						formatter.dateFormat = "yyyy-MM-dd HH:mm:SS Z"
						let someDateTime = formatter.date(from: lineData[0])
						thisLine.dategenerated = Int((someDateTime?.timeIntervalSince1970)! * 1000)

						var skip = false
						if let n1 = request.param(name: "param1_n"), lineData.count > 1 {
							excl1?.forEach{
								excl in
								if lineData[1] == excl {
//									print("SKIPPING 1")
									skip = true
								}
							}
							thisLine.detail[n1] = lineData[1]
						}
						if let n2 = request.param(name: "param2_n"), lineData.count > 2 {
							excl2?.forEach{
								excl in
								if lineData[2] == excl {
//									print("SKIPPING 2")
									skip = true
								}
							}
							thisLine.detail[n2] = lineData[2]
						}
						if let n3 = request.param(name: "param3_n"), lineData.count > 3 {
							excl3?.forEach{
								excl in
								if lineData[3] == excl {
//									print("SKIPPING 3")
									skip = true
								}
							}
							thisLine.detail[n3] = lineData[3]
						}
						if !skip {
//							print(thisLine.detail)
							try thisLine.save()
						}
					}
				} catch {
					print("\(error)")
				}
			}
//			this.dategenerated =
				//Int(Date().timeIntervalSince1970 * 1000)
		}





//		let tokens = AppToken.listTokens(account: contextAccountID)
		let tokens = AppToken.listTokens()
//		let apps = Application.listApps(account: contextAccountID)
		let apps = Application.listApps()

		var context: [String : Any] = [
			"accountID": contextAccountID,
			"authenticated": contextAuthenticated,
			"tokenlist": tokens,
			"applist": apps,
			"token": request.user.authDetails?.sessionID ?? ""
		]
		if contextAuthenticated {
			for i in WebHandlers.extras() {
				context[i.0] = i.1
			}
		}
		response.render(template: "import", context: context)
	}
	
	



}
