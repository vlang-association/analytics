module main

import os
import regex

fn clean_output_directory() ! {
	if os.exists(output_path) {
		os.rmdir_all(output_path)!
	}
}

fn create_output_directory() ! {
	mkdir_if_not_exists(output_path)!
}

fn mkdir_if_not_exists(path string) ! {
	if !os.exists(path) {
		os.mkdir_all(path, os.MkdirParams{})!
	}
}

fn copy_assets_to_output() ! {
	os.cp_all(assets_path, os.join_path(output_path, 'assets'), true)!
}

fn write_output_file(filename string, content string) ! {
	os.write_file(os.join_path(output_path, filename), content)!
}

fn title_to_filename(title string) string {
	filename := title.replace_each([' ', '-', '`', '', '/', '', '\\', '', ':', '', '&', '', '(',
		'', ')', '']).to_lower()

	return '${filename}'
}

fn extract_title_from_markdown_topic(source string) ?string {
	mut title_re := regex.regex_opt(r'^#+') or { panic(err) }
	lines := source.split_into_lines()

	if lines.len > 0 {
		first_line := lines.first()
		title := title_re.replace(first_line, '')

		if title != '' {
			return title.trim_space()
		}
	}

	return none
}
