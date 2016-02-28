#!/bin/bash
function onchange {
	EVENTS="CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"

	if [ -z "$1" ]; then
		echo "Usage: $0 cmd ..."
		exit -1;
	fi

	inotifywait -e "$EVENTS" -m -r --format '%:e %f' . | (
	WAITING="";
	while true; do
		LINE="";
		read -t 1 LINE;
		if test -z "$LINE"; then
			if test ! -z "$WAITING"; then
				echo "CHANGE";
				WAITING="";
			fi;
		else
			WAITING=1;
		fi;
	done) | (
	while true; do
		read TMP;
		echo $@
		$@
	done
	)
}

SRC=/var/www/alchemy/alchemy-webservice/alchemy-info-tables/res/Product_Information/
DST=alchemy@223.165.64.86:/var/www/html/current/content/uploads/pdf_folders

onchange rsync -azP --delete $SRC $DST
