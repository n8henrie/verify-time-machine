#!/usr/bin/osascript -l JavaScript
'use strict'

function log(x) {
	console.log(JSON.stringify(x))
}

function debug(x) {
	log(typeof (x))
	log(x.length)
	log(x)
	for (var e of [x.uiElements, x.properties, x.entireContents]) {
		try {
			log(e())
		} catch { }
	}
}

function run(_) {
	var app = Application.currentApplication()
	app.includeStandardAdditions = true

	var system_events = Application("System Events")

	// for testing
	// let verify_name = "Open Time Machine Settings…"	
	let verify_name = "Verify Backups"

	let verify_candidates = system_events
		.processes["SystemUIServer"]
		.menuBars[0]
		.menuBarItems
		.menus
		.menuItems
		.whose(
			{name: {"=": verify_name}}
		)

	let verify
	if (verify_candidates.length == 1) {
		verify = verify_candidates[0]
	} else {
		throw new Error("Did not find 1 exact match for verify button")
	}
	verify.click()
}

