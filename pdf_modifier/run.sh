#!/bin/bash
source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/bash-oo-framework/lib/oo-bootstrap.sh"
import util/exception
import util/tryCatch

# Script to add a header or a footer to a PDF file
# execute this script as follows:
# $ ./run.sh -l -t sds.tex "my document.pdf"
# or
# $ ./run.sh -t pds.tex "my document.pdf"

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
LANDSCAPE=0

while getopts "lt:" opt; do
	case "$opt" in
		l)  LANDSCAPE=1
			;;
		t)  TEMPLATE=$OPTARG
			;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

FILENAME=$1

if [ -z "$FILENAME" ]; then
	exit 1
fi

if [ "$LANDSCAPE" == "0" ]; then
	LANDSCAPE=""
	SCALE="0.9"
else
	LANDSCAPE=", landscape"
	SCALE="0.85"
fi

if [ ! -f $TEMPLATE ]; then
	echo "Template not found"
	exit 1
fi

# Create hashed tmp directory so that conflicts are less likely to happen
MD5SUM=$(md5sum "$FILENAME" | awk '{ print $1 }')
TMP_DIR=tmp_dir_$MD5SUM
OUTPUT_DIR=output
BASENAME=$(basename "$FILENAME")

mkdir -p $TMP_DIR
mkdir -p $OUTPUT_DIR


cp "$FILENAME" "$TMP_DIR/"

# Attempt to repair pdf
try {
	gs \
	-o "$TMP_DIR/repaired.pdf" \
	-sDEVICE=pdfwrite \
	-dPDFSETTINGS=/prepress \
	"$TMP_DIR/$BASENAME"
	mv "$TMP_DIR/repaired.pdf" "$TMP_DIR/$BASENAME"
} catch {
	echo "Repair failed, moving on..."
	rm -f "$TMP_DIR/repaired.pdf"
}

# Remove encryption if possible
try {
	qpdf --decrypt "$TMP_DIR/$BASENAME" "$TMP_DIR/decrypt.pdf"
	mv "$TMP_DIR/decrypt.pdf" "$TMP_DIR/$BASENAME"
} catch {
	echo "Decrypt failed, moving on..."
	rm -f "$TMP_DIR/decrypt.pdf"
}

pdfseparate "$TMP_DIR/$BASENAME" "$TMP_DIR/tmp_%05d.pdf"

rm "$TMP_DIR/$BASENAME"

for f in "$TMP_DIR/"*; do
	cat header.tex |
	sed "s/%%FILENAME%%/$(echo $f | sed -e 's/[\/&]/\\&/g')/" |
	sed "s/%%LANDSCAPE%%/$LANDSCAPE/" |
	sed "s/%%SCALE%%/$SCALE/" |
	sed "s/%%TEMPLATE%%/$TEMPLATE/" |
	pdflatex &>/dev/null && rm texput.log texput.aux
	# Pipe output to /dev/null and delete .log and .aux

	rm "$f"
	mv texput.pdf "$f"
done

pdfunite $TMP_DIR/tmp_* "$TMP_DIR/$BASENAME.new"

NOEXT="${FILENAME%.*}"

mv "$TMP_DIR/$BASENAME.new" "${OUTPUT_DIR}/${BASENAME}"
rm -rf $TMP_DIR
