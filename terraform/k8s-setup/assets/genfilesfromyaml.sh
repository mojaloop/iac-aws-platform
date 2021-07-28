OUTPUT_VAR=$1
FILE_EXT=$2
CERT_PATH=$3
INPUT_FILE=$4
yq -M e '.items | keys' $INPUT_FILE | sed 's/^- //g' | while IFS= read -r line; do
  FILTER="e '.items[\"$line\"]."$OUTPUT_VAR"'"
  eval "yq" $FILTER $INPUT_FILE > "$CERT_PATH/${line}$FILE_EXT"
done