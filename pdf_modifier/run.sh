#!/bin/bash

# Script to add a header or a footer to a PDF file
# execute this script as follows:
# $ ./run.sh "my document.pdf" -l -t header.tex
# or
# $ ./run.sh "my document.pdf" -t footer.tex

# A POSIX variable
OPTIND=1 # Reset in case getopts has been used previously in the shell.

# Initialize our own variables:
LANDSCAPE=0
TEMPLATE="header.tex"

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

# Remove encryption if possible
qpdf --decrypt "$TMP_DIR/$BASENAME" "$TMP_DIR/decrypt.pdf"
mv "$TMP_DIR/decrypt.pdf" "$TMP_DIR/$BASENAME"

pdfseparate "$TMP_DIR/$BASENAME" "$TMP_DIR/tmp_%05d.pdf"


FIRST=$(ls $TMP_DIR | grep tmp_ | head -1)
FIRST=$(echo $TMP_DIR/$FIRST | sed -e 's/[\/&]/\\&/g')

cat $TEMPLATE | sed "s/%%FILENAME%%/$FIRST/" | sed "s/%%LANDSCAPE%%/$LANDSCAPE/" | sed "s/%%SCALE%%/$SCALE/" | pdflatex &>/dev/null && rm texput.log texput.aux

rm "$TMP_DIR/$BASENAME"
mv texput.pdf $TMP_DIR/tmp_00001.pdf

pdfunite $TMP_DIR/tmp_* "$TMP_DIR/$BASENAME.new"

NOEXT="${FILENAME%.*}"

mv "$TMP_DIR/$BASENAME.new" "${OUTPUT_DIR}/${BASENAME}"
rm -rf $TMP_DIR
