//
//  APIRoutes.swift
//  Perfect-LogServer
//
//  Created by Jonathan Guthrie on 2016-11-11.
//
//

import PerfectHTTP
import PostgresStORM
import Foundation

func apiRoutes() -> Routes {
	var r = Routes()

	r.add(method: .post, uri: "/api/v1/log/{token}", handler: logLog)
	r.add(method: .get, uri: "/check", handler: checkme)

	return r
}
