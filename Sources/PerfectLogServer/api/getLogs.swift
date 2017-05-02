//
//  getLogs.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import PerfectHTTP
import PostgresStORM
import SwiftMoment

extension APIRoutes {
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

	static func logGetLog(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

		//	let contextAccountID = request.session?.userid
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated {
				badRequest(request, response, msg: "Unauthenticated")
				return
			}

			var token = ""
		//	var loglevel = ""
			var whereclause = ""
			var params = [String]()

			if let tokenin = request.urlVariables["token"], !tokenin.isEmpty {
				token = tokenin
			} else {
				guard let body = request.postBodyString, body.characters.count > 0 else {
					badRequest(request, response, msg: "Invalid data")
					return
				}
				var incoming = [String: Any]()
				do {
					incoming = try body.jsonDecode() as? [String: Any] ?? [String: Any]()
					//print(incoming)
					if let tokenin = incoming["token"] {
						token = tokenin as? String ?? ""
						params.append(token)
					}
					if let loglevelin = incoming["loglevel"], !(loglevelin as? String ?? "").isEmpty {
						whereclause += " AND loglevel = $2"
						params.append(loglevelin as? String ?? "")
					}
					if let eventidin = incoming["eventid"], !(eventidin as? String ?? "").isEmpty {
						whereclause += " AND eventid = $\(params.count + 1)"
						params.append(eventidin as? String ?? "")
					}

					// process props
					if let propin = incoming["prop"], !(propin as? String ?? "").isEmpty, let propdatain = incoming["propdata"], !(propdatain as? String ?? "").isEmpty {
						// not safe yet
						whereclause += " AND detail @> '{\"\(propin)\": \"\(propdatain)\"}'::jsonb"


					}


				} catch {
					badRequest(request, response, msg: "Please supply a valid token")
					return
				}
			}

			if token.isEmpty {
				badRequest(request, response, msg: "Please supply a valid token")
				return
			}

			let t = LogData()

			do {
				try t.select(whereclause: "token = $1 \(whereclause)", params: params, orderby: ["dategenerated DESC"])
			} catch {
				print("select: \(error)")
			}

			do {
				try response.setBody(json: ["results":t.asObject()])
			} catch {
				print("setBody: \(error)")
			}
			response.completed()

		}
	}
}
