module models

pub enum EventKind {
	page_view
}

pub enum SiteId {
	playground
}

[table: 'analytics']
pub struct AnalyticsEvent {
pub:
	id         int    [primary]
	url        string // event page url
	event_kind int    // actually EventKind
	site_id    int    // actually SiteId
pub mut:
	user_agent      string // user agent of the user
	accept_language string // accept language of the user
	created_at      i64    // utc timestamp
}
