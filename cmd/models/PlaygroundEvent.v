module models

pub enum PlaygroundEventKind {
	run
	test
	cgen
	share
	format
	create_bug
}

[table: 'playground_analytics']
pub struct PlaygroundEvent {
pub:
	id int [primary]

	kind int // actually PlaygroundEventKind

	build_arguments   string
	run_arguments     string
	run_configuration int

	code         string // if is_cgen_fail is true, this is the code that failed to compile
	output       string // if is_cgen_fail is true, this is the cgen error message
	is_cgen_fail bool   // true if code compilation failed due to cgen error
pub mut:
	created_at i64 // utc timestamp
}
