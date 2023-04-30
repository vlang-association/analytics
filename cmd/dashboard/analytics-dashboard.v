module main

import vweb
import db.sqlite
import cmd.models
import os
import flag
import time
import arrays

const (
	template_path = './templates/index.html'
)

struct FetchedData {
mut:
	updated_at time.Time

	playground_views int
	docs_views       int
	blog_views       int
	modules_views    int
	main_page_views  int
	intellij_v_views int

	country_map map[string]int
}

struct Server {
	vweb.Context
mut:
	db   sqlite.DB
	data FetchedData [vweb_global]
}

fn (mut s Server) update_analytics_data() {
	for {
		println('Updating analytics data')

		s.data.playground_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 0
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.docs_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 1
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.blog_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 2
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.modules_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 3
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.main_page_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 4
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.intellij_v_views = sql s.db {
			select count from models.AnalyticsEvent where site_id == 5
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.updated_at = time.now()

		res, _ := s.db.exec('SELECT country_name, SUM(1) FROM analytics GROUP BY country_name')

		s.data.country_map = map[string]int{}
		for row in res {
			country, country_count := row.vals[0], row.vals[1]
			if country.trim(' ').len == 0 {
				continue
			}
			s.data.country_map[country] = country_count.int()
		}

		time.sleep(5 * time.minute)
	}
}

['/']
fn (mut s Server) index() vweb.Result {
	per_site_views := [
		s.data.main_page_views,
		s.data.docs_views,
		s.data.playground_views,
		s.data.blog_views,
		s.data.modules_views,
		s.data.intellij_v_views,
	]
	all_views := arrays.sum(per_site_views) or { 0 }
	per_sites_data := per_site_views.map(it.str()).join(', ')

	per_countries_labels := s.data.country_map.keys().map('"${it}"').join(', ')
	per_countries_data := s.data.country_map.values().map(it.str()).join(', ')
	countries_count := s.data.country_map.len

	title := 'Dashboard'
	updated_at := s.data.updated_at.format_ss()
	now := time.now().custom_format('YYYY')

	return s.html($tmpl(template_path))
}

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	port := fp.int('port', `p`, 8102, 'Port to listen on')

	db := sqlite.connect('db.sqlite') or { panic(err) }

	mut server := &Server{
		db: db
	}

	spawn server.update_analytics_data()

	if !server.handle_static('./cmd/dashboard/templates/assets', true) {
		panic('Failed to load static assets')
	}
	server.serve_static('/', './cmd/dashboard/templates/assets')

	vweb.run(server, port)
}
