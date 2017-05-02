//
//  Setup.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2017-01-05.
//
//


//
//  InitializeSchema.swift
//  Perfect-OAuth2-Server
//
//  Created by Jonathan Guthrie on 2017-02-06.
//
//
import JSONConfig


public func additionalInitializeSchema(_ fname: String = "./config/ApplicationConfiguration.json") -> [String:Any] {
	var opts = [String:Any]()
	if let config = JSONConfig(name: fname) {
		let dict = config.getValues()!
		opts["httpPort"] = dict["httpport"] as! Int

		opts["baseURL"] = dict["baseURL"] as? String ?? ""
		opts["domain"] = dict["domain"] as? String ?? ""

	} else {
		print("Unable to get Configuration")

	}

	return opts
}


func setup() {

//	// db Setup
//	// Set up the Authentication table
//	let auth = AuthAccount()
//	try? auth.setup()
//
//	// Make sure there is at least 1 user:
//	let usersCount = AuthAccount()
//	try? usersCount.findAll()
//	if usersCount.results.cursorData.totalRecords == 0 {
//		// make default user:
//		let user = AuthAccount()
//		user.username = "admin"
//		user.firstname = "Admin"
//		user.lastname = "Admin"
//		user.password = BCrypt.hash(password: "perfect")
//		let random: Random = URandom()
//		user.id(String(random.secureToken))
//		try? user.create()
//	}
//
//
//	// Connect the AccessTokenStore
//	tokenStore = AccessTokenStore()
//	try? tokenStore?.setup()


	// LogData
	let logData = LogData()
	try? logData.setup()

	// Applications
	let appdata = Application()
	try? appdata.setup()

	// App Tokens
	let tokendata = AppToken()
	try? tokendata.setup()

	// App Tokens
	let graphdata = GraphSave()
	try? graphdata.setup()
}
