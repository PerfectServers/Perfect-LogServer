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

enum LogLevel {
	case warn, info, debug, error, critical

}

class LogData: PostgresStORM {
	var id					= 0
	var appuuid				= ""
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
		self.appuuid		= this.data["appuuid"] as? String ?? ""
		self.loglevel		= logLevelFromString(this.data["loglevel"] as? String ?? "")
		if let detailObj = this.data["detail"] {
			do {
				try self.detail = ((detailObj as? String ?? "").jsonDecode() as? [String:Any])!
			} catch {
				print(error)
			}
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

}

