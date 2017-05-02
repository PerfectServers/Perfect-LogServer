//
//  APIHandlers.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-18.
//
//

import PerfectHTTP
import PostgresStORM
import Foundation


extension APIRoutes {
	static func logLog(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			var resp = [String: Any]()

			guard let token = request.urlVariables["token"] else {
				// set an error response to be returned
				response.status = .badRequest
				resp["error"] = "Please supply a valid token"
				do {
					try response.setBody(json: resp)
				} catch {
					print(error)
				}
				response.completed()
				return
			}

			// check token here


			guard let body = request.postBodyString, body.characters.count > 0 else {
				// set an error response to be returned
				response.status = .badRequest
				resp["error"] = "Invalid body"
				do {
					try response.setBody(json: resp)
				} catch {
					print(error)
				}
				response.completed()
				return
			}
			var incoming = [String: Any]()
			do {
				incoming = try body.jsonDecode() as? [String: Any] ?? [String: Any]()

				let this = LogData()

				this.token = token

				if let appuuid = incoming["appuuid"] {
					this.appuuid = appuuid as? String ?? ""
				}
				if let eventid = incoming["eventid"] {
					this.eventid = eventid as? String ?? ""
				}
				if let loglevel = incoming["loglevel"] {
					this.loglevel = this.logLevelFromString(loglevel as? String ?? "")
				}
				if let detail = incoming["detail"] {
					this.detail = detail as? [String:Any] ?? [String:Any]()
				}

				this.dategenerated = Int(Date().timeIntervalSince1970 * 1000)
				try this.save()
				resp["error"] = "none"

			} catch {
				response.status = .badRequest
				resp["error"] = "Invalid body content"
				do {
					try response.setBody(json: resp)
				} catch {
					print(error)
				}
				response.completed()
				return

			}



			do {
				try response.setBody(json: resp)
			} catch {
				print(error)
			}
			response.completed()
			
		}
	}
}
