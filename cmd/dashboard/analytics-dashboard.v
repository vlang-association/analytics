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

	today_views_increase int

	uniques_count int

	visits_by_day map[int]int

	countries_count int
	country_map     map[string]int

	top_10_documentation_pages map[string]int
	top_10_modules_pages       map[string]int
	top_10_blog_pages          map[string]int
}

struct Server {
	vweb.Context
mut:
	db   sqlite.DB
	data FetchedData [vweb_global]
}

fn (mut s Server) get_top_10_pages(site_id int) map[string]int {
	top_10_documentation_pages, _ := s.db.exec('
		SELECT url, count(1)
		FROM analytics
		WHERE site_id == ${site_id}
		GROUP BY url
		ORDER BY count(*) DESC
		LIMIT 10
	'.trim_indent())

	mut top_10_documentation_pages_map := map[string]int{}
	for row in top_10_documentation_pages {
		url, count := row.vals[0], row.vals[1]
		top_10_documentation_pages_map[url] = count.int()
	}

	return top_10_documentation_pages_map
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

		now := time.now()
		today_start := time.new_time(year: now.year, month: now.month, day: now.day).unix_time()

		s.data.today_views_increase = sql s.db {
			select count from models.AnalyticsEvent where created_at > today_start
		} or {
			eprintln('Database Error: ${err}')
			return
		}

		s.data.updated_at = now

		country_res_rows, _ := s.db.exec('
			SELECT country_name, SUM(1)
			FROM analytics
			GROUP BY country_name
			ORDER BY count(*) DESC
		'.trim_indent())

		s.data.countries_count = country_res_rows.len
		s.data.country_map = map[string]int{}
		for index, row in country_res_rows {
			country, country_count := row.vals[0], row.vals[1]
			if country.trim(' ').len == 0 {
				continue
			}
			s.data.country_map[country] = country_count.int()

			if index >= 30 {
				break
			}
		}

		uniques_rows, _ := s.db.exec('
			SELECT SUM(1)
			FROM analytics
			GROUP BY country_name, city_name, user_agent, accept_language
			ORDER BY count(*) DESC
		'.trim_indent())

		s.data.uniques_count = uniques_rows.len

		s.data.top_10_documentation_pages = s.get_top_10_pages(1)
		s.data.top_10_blog_pages = s.get_top_10_pages(2)
		s.data.top_10_modules_pages = s.get_top_10_pages(3)

		visits_by_day, _ := s.db.exec("
			SELECT COUNT(*)               		 AS visits,
       			   DATE(created_at, 'unixepoch') AS date,
       			   created_at
			FROM analytics
			WHERE date > DATETIME('now', '-7 days')
			GROUP BY date
			ORDER BY date;
		".trim_indent())

		for row in visits_by_day {
			visits, created_at := row.vals[0], row.vals[2]
			s.data.visits_by_day[created_at.int()] = visits.int()
		}

		// Visitors by days for the last 7 days.
		// SELECT
		//	COUNT(*) AS visitors,
		//	date
		// FROM (
		//	SELECT
		//		SUM(1),
		//		DATE(created_at, 'unixepoch') AS date
		//	FROM
		//		analytics
		//	WHERE
		//		date > DATETIME ('now', '-7 days')
		//	GROUP BY
		//		country_name,
		//		city_name,
		//		user_agent,
		//		accept_language)
		// GROUP BY
		//	date
		// ORDER BY
		//	date DESC;

		time.sleep(5 * time.minute)
	}
}

fn (mut _ Server) top_10_to_table(data map[string]int) string {
	mut top_10_rows := ''
	for url, count in data {
		top_10_rows += '
		<tr>
			<td><a href="${url}">${url}</td>
			<td>${count}</td>
		</tr>
'.trim_indent()
	}
	return top_10_rows
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
	all_views_today_increase := s.data.today_views_increase
	per_sites_data := per_site_views.map(it.str()).join(', ')

	last_7_day_labels := s.data.visits_by_day.keys()
		.map(time.unix(it).custom_format('DD.MM'))
		.map('"${it}"')
		.join(', ')
	last_7_day_data := s.data.visits_by_day.values().map(it.str()).join(', ')

	per_countries_labels := s.data.country_map.keys().map('"${it}"').join(', ')
	per_countries_data := s.data.country_map.values().map(it.str()).join(', ')
	countries_count := s.data.countries_count

	uniques_count := s.data.uniques_count

	top_10_documentation_pages_rows := s.top_10_to_table(s.data.top_10_documentation_pages)
	top_10_modules_pages_rows := s.top_10_to_table(s.data.top_10_modules_pages)
	top_10_blog_pages_rows := s.top_10_to_table(s.data.top_10_blog_pages)

	title := 'Dashboard'
	updated_at := s.data.updated_at.format_ss()
	now := time.now().custom_format('YYYY')

	start_date := time.unix(1682781259).format_ss()

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
