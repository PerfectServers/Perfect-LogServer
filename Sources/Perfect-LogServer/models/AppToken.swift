//
//  AppToken.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-18.
//
//


import StORM
import PostgresStORM
import PerfectLib
//import SwiftRandom
import Foundation
import SwiftMoment

class AppToken: PostgresStORM {
	var id					= 0
	var token				= ""
	var name				= ""
	var accountid			= ""
	var dategenerated		= 0
	var valid				= false


	// Set the table name
	override open func table() -> String {
		return "apptokens"
	}

	// Need to do this because of the nature of Swift's introspection
	override func to(_ this: StORMRow) {
		self.id				= this.data["id"] as? Int ?? 0
		self.token			= this.data["token"] as? String ?? ""
		self.name			= this.data["name"] as? String ?? ""
		self.accountid		= this.data["accountid"] as? String ?? ""
		self.dategenerated	= this.data["dategenerated"] as? Int ?? 0
		self.valid			= this.data["valid"] as? Bool ?? false
	}

	func rows() -> [AppToken] {
		var rows = [AppToken]()
		for i in 0..<self.results.rows.count {
			let row = AppToken()
			row.to(self.results.rows[i])
			rows.append(row)
		}
		return rows
	}

	func newToken(account: String, tokenName: String) -> String {
		id = 0
		token = UUID().string
		name = tokenName
		accountid = account
		let th = moment()
		dategenerated = Int(th.epoch())
		valid = true
		do {
			try save()
		} catch {
			print("Error creating new token: \(error)")
			return ""
		}
		return token
	}

	static func tokenMap() -> [String:String] {
		let tokens = AppToken()
		try? tokens.findAll()
		var tokenMap = [String:String]()
		tokens.rows().forEach{tokenMap[$0.token] = $0.name}
		return tokenMap
	}

	static func listTokens(account: String) -> [[String: Any]] {
		var tokens = [[String: Any]]()
		let t = AppToken()
		var findCriteria = [(String,Any)]()
		findCriteria.append(("accountid",account))
		try? t.find(findCriteria)


		for row in t.rows() {
			var r = [String: Any]()
			r["token"] = row.token
			r["accountid"] = row.accountid
			r["name"] = row.name
			r["dategenerated"] = moment(row.dategenerated * 1000)
			if row.valid {
				r["valid"] = "Valid"
			} else {
				r["valid"] = "Expired"
			}
			tokens.append(r)
		}
		return tokens
	}

}

