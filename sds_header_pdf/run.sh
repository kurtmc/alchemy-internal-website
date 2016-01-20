#!/bin/bash

FILENAME=$1

if [ -z "$FILENAME" ]; then
	echo "Usage: append-footer <filename>"
	exit
fi

LANDSCAPE=$2
if [ -z "$LANDSCAPE" ]; then
	LANDSCAPE=""
	SCALE="0.9"
else
	LANDSCAPE=", landscape"
	SCALE="0.85"
fi


TMP_DIR=tmp_dir
OUTPUT_DIR=output
BASENAME=$(basename "$FILENAME")

rm -rf $TMP_DIR
mkdir -p $TMP_DIR
mkdir -p $OUTPUT_DIR


cp "$FILENAME" "$TMP_DIR/"

pdfseparate "$TMP_DIR/$BASENAME" "$TMP_DIR/tmp_%05d.pdf"


FIRST=$(ls $TMP_DIR | grep tmp_ | head -1)
FIRST=$(echo $TMP_DIR/$FIRST | sed -e 's/[\/&]/\\&/g')

cat header.tex | sed "s/%%FILENAME%%/$FIRST/" | sed "s/%%LANDSCAPE%%/$LANDSCAPE/" | sed "s/%%SCALE%%/$SCALE/" | pdflatex &>/dev/null && rm texput.log texput.aux

rm "$TMP_DIR/$BASENAME"
mv texput.pdf $TMP_DIR/tmp_00001.pdf

pdfunite $TMP_DIR/tmp_* "$TMP_DIR/$BASENAME.new"

NOEXT="${FILENAME%.*}"

mv "$TMP_DIR/$BASENAME.new" "${OUTPUT_DIR}/${BASENAME}"
