#!/bin/bash

SRC=/var/www/alchemy/alchemy-webservice/alchemy-info-tables/res/Product_Information/
DST=alchemy@223.165.64.86:/var/www/html/current/content/uploads/pdf_folders

function onchange {
	EVENTS="CREATE,CLOSE_WRITE,DELETE,MODIFY,MOVED_FROM,MOVED_TO"

	inotifywait -e "$EVENTS" -m -r --format '%:e %f' /var/www/alchemy/alchemy-webservice/alchemy-info-tables/res/Product_Information | (
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
		echo su - alchemy -c "/usr/bin/rsync -azP --delete $SRC $DST"
		su - alchemy -c "/usr/bin/rsync -azP --delete $SRC $DST"
	done
	)
}

onchange 
