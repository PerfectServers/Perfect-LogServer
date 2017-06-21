// Generated automatically by Perfect Assistant Application
// Date: 2017-04-28 14:59:47 +0000
import PackageDescription
let package = Package(
	name: "PerfectLogServer",
	targets: [
		Target(
			name: "PerfectLogServer",
			dependencies: []
		)
	],
	dependencies: [
		.Package(url: "https://github.com/iamjono/JSONConfig.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-RequestLogger.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-SMTP", majorVersion: 1),
		.Package(url: "https://github.com/SwiftORM/Postgres-StORM.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Session-PostgreSQL.git", majorVersion: 1),
		.Package(url: "https://github.com/PerfectlySoft/Perfect-Mustache.git", majorVersion: 2),

		.Package(url: "https://github.com/PerfectlySoft/Perfect-LocalAuthentication-PostgreSQL.git", majorVersion: 1),

	]
)
