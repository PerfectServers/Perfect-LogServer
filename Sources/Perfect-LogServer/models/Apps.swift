//
//  Apps.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import StORM
import PostgresStORM
import PerfectLib
import Foundation
import SwiftMoment

class Application: PostgresStORM {
	var id					= 0
	var appuuid				= ""
	var accountid			= ""
	var name				= ""
	var dategenerated		= 0
	var valid				= false


	// Set the table name
	override open func table() -> String {
		return "applications"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		self.id				= this.data["id"] as? Int ?? 0
		self.appuuid		= this.data["appuuid"] as? String ?? ""
		self.accountid		= this.data["accountid"] as? String ?? ""
		self.name			= this.data["name"] as? String ?? ""
		self.dategenerated	= this.data["dategenerated"] as? Int ?? 0
		self.valid			= this.data["valid"] as? Bool ?? false
	}

	func rows() -> [Application] {
		var rows = [Application]()
		for i in 0..<self.results.rows.count {
			let row = Application()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	func newApplication(account: String, appName: String) -> String {
		id = 0
		appuuid = UUID().string
		accountid = account
		name = appName
		let th = moment()
		dategenerated = Int(th.epoch())
		valid = true
		do {
			try save()
		} catch {
			print("Error creating new app: \(error)")
			return ""
		}
		return appuuid
	}



	static func listApps(account: String = "") -> [[String: Any]] {
		var apps = [[String: Any]]()
		let t = Application()
		var findCriteria = [(String,Any)]()
		if account.isEmpty {
			try? t.findAll()
		} else {
			findCriteria.append(("accountid",account))
			try? t.find(findCriteria)
		}

		for row in t.rows() {
			var r = [String: Any]()
			r["appuuid"] = row.appuuid
			r["accountid"] = row.accountid
			r["name"] = row.name
			r["dategenerated"] = moment(row.dategenerated * 1000)
			if row.valid {
				r["valid"] = "Valid"
			} else {
				r["valid"] = "Expired"
			}
			apps.append(r)
		}
		return apps
	}

	static func appMap() -> [String:String] {
		let apps = Application()
		try? apps.findAll()
		var appMap = [String:String]()
		apps.rows().forEach{appMap[$0.appuuid] = $0.name}
		return appMap
	}

}

