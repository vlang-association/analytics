module main

import vweb
import json
import time
import flag
import os
import cmd.models
import net.http
import db.sqlite

struct Server {
	vweb.Context
mut:
	db sqlite.DB
}

['/']
fn (mut s Server) index() vweb.Result {
	return s.text('Hello, I am a web server for VOSCA analytics\n')
}

['/a'; post]
fn (mut s Server) analytics() vweb.Result {
	println('Got analytics event from ${s.ip()}')

	mut data := json.decode(models.AnalyticsEvent, s.req.data) or {
		eprintln('Invalid JSON: ' + s.req.data)
		s.set_status(400, 'Bad Request')
		return s.text('Invalid JSON')
	}

	if data.user_agent == '' {
		data.user_agent = s.req.header.get(http.CommonHeader.user_agent) or { '' }
	}

	if data.accept_language == '' {
		data.accept_language = s.req.header.get(http.CommonHeader.accept_language) or { '' }
	}

	data.created_at = time.utc().unix_time()

	sql s.db {
		insert data into models.AnalyticsEvent
	} or {
		s.set_status(500, 'Internal Server Error')
		return s.text('Database Error')
	}

	println('Analytics event saved')
	s.set_status(200, 'OK')
	return s.text('OK')
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	port := fp.int('port', `p`, 8100, 'Port to listen on')

	db := sqlite.connect('db.sqlite') or { panic(err) }

	sql db {
		create table models.AnalyticsEvent
	} or { panic(err) }

	vweb.run(&Server{
		db: db
	}, port)
}
