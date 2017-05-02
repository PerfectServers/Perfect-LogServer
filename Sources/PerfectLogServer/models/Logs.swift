//
//  Logs.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-11.
//
//

import StORM
import PostgresStORM
import PerfectLib
import SwiftMoment

enum LogLevel {
	case warn, info, debug, error, critical

}

class LogData: PostgresStORM {
	var id					= 0
	var token				= ""
	var appuuid				= ""
	var eventid				= ""
	var loglevel			= LogLevel.info
	var detail				= [String:Any]()
	var dategenerated		= 0


	// Set the table name
	override open func table() -> String {
		return "logs"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		self.id				= this.data["id"] as? Int ?? 0
		self.token			= this.data["token"] as? String ?? ""
		self.appuuid		= this.data["appuuid"] as? String ?? ""
		self.eventid		= this.data["eventid"] as? String ?? ""
		self.loglevel		= logLevelFromString(this.data["loglevel"] as? String ?? "")
		if let detailObj = this.data["detail"] {
			self.detail = detailObj as? [String:Any] ?? [String:Any]()
		}
		self.dategenerated = this.data["dategenerated"] as? Int ?? 0
	}

	func rows() -> [LogData] {
		var rows = [LogData]()
		for i in 0..<self.results.rows.count {
			let row = LogData()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	func logLevelFromString(_ str: String) -> LogLevel {
		switch str {
		case "warn":
			return LogLevel.warn
		case "debug":
			return LogLevel.debug
		case "error":
			return LogLevel.error
		case "critical":
			return LogLevel.critical
		default:
			return LogLevel.info
		}
	}

	func distinctTokens(_ restrict: Int = 10) -> [[String:String]] {
		let tokenMap = AppToken.tokenMap()

		// TODO: Make params ANY
		let rowsfound = try? sqlRows("SELECT DISTINCT(token) as token FROM logs WHERE token IS NOT NULL LIMIT $1", params: [String(restrict)])

		var res = [[String:String]]()
		let counter = rowsfound?.count ?? 0
		// later when stable, make using map
		for i in 0..<counter {
			let t = rowsfound?[i].data["token"] as? String ?? ""
			res.append(["token":t, "tokenName": tokenMap[t] ?? ""])
		}
		return res
	}
	func distinctApps(_ restrict: Int = 10) -> [[String:String]] {
		//SELECT DISTINCT(token) as token FROM logs WHERE token IS NOT NULL
		//let cursor = StORMCursor(limit: restrict, offset: 0)
		//try? select(columns: ["DISTINCT(token) as token"], whereclause: "token IS NOT NULL", params: [], orderby: [], cursor: cursor)

		// TODO: Make params ANY
		let rowsfound = try? sqlRows("SELECT DISTINCT(appuuid) as appuuid FROM logs WHERE appuuid IS NOT NULL LIMIT $1", params: [String(restrict)])

		var res = [[String:String]]()
		let counter = rowsfound?.count ?? 0
		// later when stable, make using map
		for i in 0..<counter {
			res.append(["app":(rowsfound?[i].data["appuuid"] as? String ?? "")])
		}
		return res
	}


	func asObject() -> [[String: Any]] {

		let appMap = Application.appMap()
		let tokenMap = AppToken.tokenMap()

		var logEntries = [[String: Any]]()

		for row in rows() {
			var r = [String: Any]()
			r["id"]				= row.id
			r["token"]			= row.token
			r["tokenName"]		= tokenMap[row.token]
			r["appuuid"]		= row.appuuid
			r["appName"]		= appMap[row.appuuid]
			r["eventid"]		= row.eventid
			r["loglevel"]		= String(describing: row.loglevel)
			r["detail"]			= row.detail
			let m = moment(row.dategenerated)

			r["dategenerated"]	= m.format()
			logEntries.append(r)
		}
		return logEntries
	}
}

