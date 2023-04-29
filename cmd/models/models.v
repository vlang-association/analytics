module models

import net.urllib

pub enum EventKind {
	page_view
}

pub enum SiteId {
	playground
	docs
	blog
	modules
	main_page
	unknown = -1
}

pub fn site_id_from_url(path string) SiteId {
	url := urllib.parse(path) or { return .unknown }

	return match url.host {
		'play.vosca.dev' { .playground }
		'docs.vosca.dev' { .docs }
		'blog.vosca.dev' { .blog }
		'modules.vosca.dev' { .modules }
		'vosca.dev' { .main_page }
		else { .unknown }
	}
}

[table: 'analytics']
pub struct AnalyticsEvent {
pub:
	id         int    [primary]
	url        string // event page url
	event_kind int    // actually EventKind
pub mut:
	site_id         int    // actually SiteId
	user_agent      string // user agent of the user
	accept_language string // accept language of the user
	referrer        string // referrer url
	created_at      i64    // utc timestamp
}
