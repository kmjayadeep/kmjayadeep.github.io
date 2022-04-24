#!/bin/sh -e

## Static site generator
# Dependencies: lowdown

title="Jayadeep's blog"

main() {
	test -n "$1" || usage

	h_file="src/_header.html"
	f_file="src/_footer.html"
	test -f "$f_file" && FOOTER=$(cat "$f_file") && export FOOTER
	test -f "$h_file" && HEADER=$(cat "$h_file") && export HEADER

  files=`ls src/*.md`
  for f in $files
  do
    basename $f | render_md_files_lowdown src dest
  done


}

usage() {
	echo "usage: ${0##*/} render" >&2
	exit 1
}

render_md_files_lowdown() {
	while read -r f; do
		lowdown \
			--html-no-escapehtml \
			--html-no-skiphtml \
			--parse-no-metadata \
			--parse-no-autolink <"$1/$f" |
			render_html_file \
				>"$2/${f%\.md}.html"
	done
}

render_html_file() {
	awk -v title="$title" '
	{ body = body "\n" $0 }
	END {
		body = substr(body, 2)
		if (body ~ /<\/?[Hh][Tt][Mm][Ll]/) {
			print body
			exit
		}
		if (match(body, /<[[:space:]]*[Hh]1(>|[[:space:]][^>]*>)/)) {
			t = substr(body, RSTART + RLENGTH)
			sub("<[[:space:]]*/[[:space:]]*[Hh]1.*", "", t)
			gsub(/^[[:space:]]*|[[:space:]]$/, "", t)
			if (t) title = t " &mdash; " title
		}
		n = split(ENVIRON["HEADER"], header, /\n/)
		for (i = 1; i <= n; i++) {
			if (match(tolower(header[i]), "<title></title>")) {
				head = substr(header[i], 1, RSTART - 1)
				tail = substr(header[i], RSTART + RLENGTH)
				print head "<title>" title "</title>" tail
			} else print header[i]
		}
		print body
		print ENVIRON["FOOTER"]
	}'
}


main "$@"
