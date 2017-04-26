//
//  graphs.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-04-25.
//
//

import PerfectHTTP
import PostgresStORM
import SwiftMoment

// POST request contains JSON Body
func logGetGraphData(request: HTTPRequest, _ response: HTTPResponse) {
	response.setHeader(.contentType, value: "application/json")

	// GraphData Container
	var graphData = [Graph]()
	var resp = [String:Any]()

	// Check Auth
	let contextAuthenticated = request.user.authenticated
	if !contextAuthenticated {
		badRequest(request, response, msg: "Unauthenticated")
		return
	}

	if let body = request.postBodyString {
		do {
			let bodyData = try body.jsonDecode() as? [String: Any] ?? [String: Any]()

			bodyData.forEach{
				n,v in
				let g = Graph()
				g.ref = n
				if v is [String: Any] {
					let vv = v as? [String: Any] ?? [String: Any]()

					// token val
					g.token = vv["token"] as? String ?? ""

					// interval
					if vv["interval"] as? String == "m" {
						g.interval = .month
					} else if vv["interval"] as? String == "y" {
						g.interval = .year
					} else {
						g.interval = .day
					}
					// process params
					if let params = vv["params"], params is [String:Any] {
						(params as! [String:Any]).forEach{
							paramName, paramVal in
							let gg = GraphParam(
								paramName as String, paramVal as? String ?? ""
							)
							g.params.append(gg)
						}
					}
				}
				graphData.append(g)
			}


		} catch {
			badRequest(request, response, msg: "Invalid data")
			return
		}
	} else {
		badRequest(request, response, msg: "Invalid data: Must be POST with JSON")
		return
	}

	graphData.forEach{
		obj in
		var whereclause = "token = $1"
		let params = [obj.token]
		obj.params.forEach{
			thisParam in
			whereclause += " AND detail->>'\(thisParam.name)' LIKE '\(thisParam.val)'"
		}
		let t = LogData()

		do {
			var grouping = "YYYY-MM-DD"
			if obj.interval == .month {
				grouping = "YYYY-MM"
			}

			let results = try t.sqlRows("SELECT to_char((to_timestamp(dategenerated/1000)::date),'\(grouping)') as ymd, COUNT(*) AS counter FROM logs WHERE \(whereclause) GROUP BY 1 ORDER BY 1 ASC", params: params)

			var resultArray = [[String: Any]]()

			// process incoming array of data
			for row in results {
				var r = [String: Any]()

				r["x"] = "\(row.data["ymd"] as! String)"
				r["y"] = row.data["counter"] as? Int ?? 0
				resultArray.append(r)
			}
			//		resultArray.reverse()

			resp[obj.ref] = resultArray

		} catch {
			print("select: \(error)")
		}

	}



	do {
		try response.setBody(json: resp)
	} catch {
		print("setBody: \(error)")
	}
	response.completed()
	
}

