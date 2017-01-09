//
//  Users.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-08.
//
//

import PerfectTurnstilePostgreSQL

extension AuthAccount {

	static func listUsers() -> [[String: Any]] {
		var users = [[String: Any]]()
		let t = AuthAccount()
		try? t.findAll()


		for row in t.rows() {
			var r = [String: Any]()
			r["uniqueid"] = row.uniqueID
			r["firstname"] = row.firstname
			r["lastname"] = row.lastname
			r["email"] = row.email
			users.append(r)
		}
		return users
	}

}
