//
//  Setup.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//

import PerfectTurnstilePostgreSQL

func setup() {

	// db Setup
	// Set up the Authentication table
	let auth = AuthAccount()
	try? auth.setup()

	// Connect the AccessTokenStore
	tokenStore = AccessTokenStore()
	try? tokenStore?.setup()


	// LogData
	let logData = LogData()
	try? logData.setup()

	// LogData
	let appdata = Application()
	try? appdata.setup()
}
