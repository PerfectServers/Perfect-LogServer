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

class GraphDataProcess {

	static func fromString(_ body: String) throws -> [Graph] {

		var graphData = [Graph]()
		let bodyData = try body.jsonDecode() as? [String: Any] ?? [String: Any]()

		bodyData.forEach{
			n,v in
			let g = Graph()
			g.ref = n
			if v is [String: Any] {
				let vv = v as? [String: Any] ?? [String: Any]()

				// token val
				g.token = vv["token"] as? String ?? ""

				// name
				if let nameof = vv["ref"] {
					g.ref = nameof as? String ?? ""
				}
				// interval
				if vv["interval"] as? String == "month" {
					g.interval = .month
				} else if vv["interval"] as? String == "year" {
					g.interval = .year
				} else {
					g.interval = .day
				}
				// process params
				if let params = vv["params"], params is [String:Any] {
					(params as? [String:Any] ?? [String: Any]()).forEach{
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
		return graphData

	}

	static func getGraphData(_ obj: Graph) -> [[String: Any]] {
		var resultArray = [[String: Any]]()

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


			// process incoming array of data
			for row in results {
				var r = [String: Any]()

				r["x"] = "\(row.data["ymd"] as? String ?? "")"
				r["y"] = row.data["counter"] as? Int ?? 0

				resultArray.append(r)
			}


		} catch {
			print("select: \(error)")
		}
		return resultArray
	}

	static func makeCumulativeArray(_ data:[[String:Any]]) -> [[String: Any]] {
		var resultArray = [[String: Any]]()
		var cumulativeCount = 0

		for datapoint in data {
			var r = [String: Any]()
			if datapoint["y"] is Int {
				cumulativeCount = cumulativeCount + (datapoint["y"] as? Int ?? 0)
			}
			r["x"] = datapoint["x"]
			r["y"] = cumulativeCount
			resultArray.append(r)

		}
		return resultArray
	}

	static func logLoadGraphData(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in
			var resp = [String:Any]()

			if let id = request.urlVariables["id"] {
				let thisGraph = GraphSave()



				do {
					try thisGraph.get(id)
					let g = thisGraph.toGraph()
					resp["config"] = ["ref": thisGraph.ref, "token":thisGraph.token, "interval": thisGraph.interval, "params": thisGraph.params]
					let gg = GraphDataProcess.getGraphData(g)
					resp[thisGraph.ref] = gg
					resp["cumulative \(thisGraph.ref)"] = GraphDataProcess.makeCumulativeArray(gg)

					try response.setBody(json: resp)
				} catch {
					APIRoutes.badRequest(request, response, msg: "ERROR: \(error)")
					print("setBody: \(error)")
				}
				response.completed()

			} else {
				APIRoutes.badRequest(request, response, msg: "Please supply a valid ID")
			}
		}
	}

	// POST request contains JSON Body
	static func logGetGraphData(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			var resp = [String:Any]()

			// Check Auth
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated {
				APIRoutes.badRequest(request, response, msg: "Unauthenticated")
				return
			}

			// GraphData Container

			if let body = request.postBodyString {
				do {
					let graphData = try fromString(body)
					graphData.forEach{
						obj in
						let gg = GraphDataProcess.getGraphData(obj)
						resp[obj.ref] = gg
						resp["cumulative \(obj.ref)"] = GraphDataProcess.makeCumulativeArray(gg)
					}
				} catch {
					APIRoutes.badRequest(request, response, msg: "Invalid data")
					return
				}
			} else {
				APIRoutes.badRequest(request, response, msg: "Invalid data: Must be POST with JSON")
				return
			}




			do {
				try response.setBody(json: resp)
			} catch {
				print("setBody: \(error)")
			}
			response.completed()
			
		}
	}


	// POST request contains JSON Body - Saves Graph
	static func logSaveGraphData(data: [String:Any]) throws -> RequestHandler {
		return {
			request, response in

			// GraphData Container
			var resp = [String:Any]()

			// Check Auth
			let contextAuthenticated = !(request.session?.userid ?? "").isEmpty
			if !contextAuthenticated {
				APIRoutes.badRequest(request, response, msg: "Unauthenticated")
				return
			}

			if let body = request.postBodyString {
				do {
					let graphData = try fromString(body)
					graphData.forEach{
						obj in
						// Translate into GraphSave and, well, save!
						let thisGraph = GraphSave()
						thisGraph.fromGraph(obj)
						do {
							try thisGraph.save()
							resp["save"] = "success"
						} catch {
							print(error)
						}
					}


				} catch {
					APIRoutes.badRequest(request, response, msg: "Invalid data")
					return
				}
			} else {
				APIRoutes.badRequest(request, response, msg: "Invalid data: Must be POST with JSON")
				return
			}




			do {
				try response.setBody(json: resp)
			} catch {
				print("setBody: \(error)")
			}
			response.completed()
			
		}
	}

}
