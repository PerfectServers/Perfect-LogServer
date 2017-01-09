//
//  Setup.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import PerfectTurnstilePostgreSQL
import TurnstileCrypto

func setup() {

	// db Setup
	// Set up the Authentication table
	let auth = AuthAccount()
	try? auth.setup()

	// Make sure there is at least 1 user:
	let usersCount = AuthAccount()
	try? usersCount.findAll()
	if usersCount.results.cursorData.totalRecords == 0 {
		// make default user:
		let user = AuthAccount()
		user.username = "admin"
		user.firstname = "Admin"
		user.lastname = "Admin"
		user.password = BCrypt.hash(password: "perfect")
		let random: Random = URandom()
		user.id(String(random.secureToken))
		try? user.create()
	}


	// Connect the AccessTokenStore
	tokenStore = AccessTokenStore()
	try? tokenStore?.setup()


	// LogData
	let logData = LogData()
	try? logData.setup()

	// Applications
	let appdata = Application()
	try? appdata.setup()

	// App Tokens
	let tokendata = AppToken()
	try? tokendata.setup()
}
