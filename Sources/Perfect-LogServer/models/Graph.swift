//
//  Graph.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-04-25.
//
//

import PostgresStORM
import StORM

class Graph {
	/// Reference to graph. Echoed back to graph api
	var ref: String = ""

	/// Token for this graph
	var token: String = ""

	/// Interval for time slice grouping
	var interval: Interval = .day

	/// Array of params
	var params: [GraphParam] = [GraphParam]()

}

struct GraphParam {
	var name: String
	var val: String
	init() {
		name = ""
		val = ""
	}
	init(_ n: String, _ p: String) {
		name = n
		val = p
	}
}
enum Interval {
	case day, month, year
}



class GraphSave: PostgresStORM {

	var id: Int = 0

	/// Reference to graph. Echoed back to graph api (aka name)
	var ref: String = ""

	/// Token for this graph
	var token: String = ""

	/// Interval for time slice grouping
	var interval: String = "day"

	/// Array of params
	var params: [String:Any] = [String:Any]()



	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		self.id				= this.data["id"] as? Int ?? 0
		self.ref			= this.data["ref"] as? String ?? ""
		self.token			= this.data["token"] as? String ?? ""
		self.interval		= this.data["interval"] as? String ?? ""
		if let detailObj = this.data["params"] {
			self.params = detailObj as? [String:Any] ?? [String:Any]()
		}
	}

	func rows() -> [GraphSave] {
		var rows = [GraphSave]()
		for i in 0..<self.results.rows.count {
			let row = GraphSave()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	func toGraph() -> Graph {
		let gg = Graph()
		gg.ref = ref
		switch interval {
		case "month":
			gg.interval = .month
		case "year":
			gg.interval = .year
		default:
			gg.interval = .day
		}
		gg.token = token
		params.forEach{
			item in
			gg.params.append(GraphParam(item.key, item.value as? String ?? ""))
		}
		return gg
	}



	func fromGraph(_ gg: Graph) {

		ref = gg.ref
		switch gg.interval {
		case .month:
			interval = "month"
		case .year:
			interval = "year"
		default:
			interval = "day"
		}
		token = gg.token
		gg.params.forEach{
			item in
			params[item.name] = item.val
		}
	}


	static func listGraphs() -> [[String: Any]] {
		var obj = [[String: Any]]()
		let t = GraphSave()
		try? t.findAll()

		for row in t.rows() {
			var r = [String: Any]()
			r["id"] = row.id
			r["ref"] = row.ref
			obj.append(r)
		}
		return obj
	}

}

