module main

import vweb
import db.sqlite
import cmd.models
import os
import flag
import time

struct FetchedData {
mut:
	updated_at time.Time

	playground_views int
	docs_views       int
	blog_views       int
	modules_views    int
	main_page_views  int
}

struct Server {
	vweb.Context
mut:
	db   sqlite.DB
	data FetchedData [vweb_global]
}

fn (mut s Server) db_error(err IError) {
	eprintln('Database Error: ${err}')
}

fn (mut s Server) update_analytics_data() {
	for {
		println('Updating analytics data')

		s.data.playground_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 0
		} or {
			s.db_error(err)
			return
		}

		s.data.docs_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 1
		} or {
			s.db_error(err)
			return
		}

		s.data.blog_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 2
		} or {
			s.db_error(err)
			return
		}

		s.data.modules_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 3
		} or {
			s.db_error(err)
			return
		}

		s.data.main_page_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 4
		} or {
			s.db_error(err)
			return
		}

		s.data.updated_at = time.now()

		time.sleep(1 * time.minute)
	}
}

['/']
fn (mut s Server) index() vweb.Result {
	// data := sql s.db {
	// 	select from models.AnalyticsEvent
	// } or {
	// 	eprintln('Database Error: ${err}')
	// 	s.set_status(500, 'Internal Server Error')
	// 	return s.text('Database Error')
	// }
	//
	// html := data.map(fn (it models.AnalyticsEvent) string {
	// 	created_at := time.unix(it.created_at)
	// 	return '<tr><td>' + it.url + '</td><td>' + created_at.format_ss() + '</td></tr>'
	// }).join('\n')

	html := '
<table>
<tr>
<td>Playground</td>
<td>${s.data.playground_views}</td>
</tr>
<tr>
<td>Docs</td>
<td>${s.data.docs_views}</td>
</tr>
<tr>
<td>Blog</td>
<td>${s.data.blog_views}</td>
</tr>
<tr>
<td>Modules</td>
<td>${s.data.modules_views}</td>
</tr>
<tr>
<td>Main page</td>
<td>${s.data.main_page_views}</td>
</tr>
</table>

<p>
Updated at ${s.data.updated_at.format_ss()}
</p>
'

	return s.html('<html><body><table>' + html + '</table></body></html>')
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	port := fp.int('port', `p`, 8102, 'Port to listen on')

	db := sqlite.connect('db.sqlite') or { panic(err) }

	mut server := &Server{
		db: db
	}

	spawn server.update_analytics_data()

	vweb.run(server, port)
}
