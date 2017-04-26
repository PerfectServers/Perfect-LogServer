//
//  Graph.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-04-25.
//
//



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
