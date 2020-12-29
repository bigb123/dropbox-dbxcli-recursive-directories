#!/usr/bin/env bash

# usage description
usage () {
  echo
  echo "Upload the directory into the Dropbox file storage using 'dbxcli' tool."
  echo 
  echo "If you skip the -d option the directory will be uploaded to the Dropbox root path." 
  echo
  echo "Usage:"
  echo "$(basename "$0") [ -d /Dropbox/destination/location ] /path/to/local/source/directory"
  echo

  exit 0
}

# Arguments handle
while getopts "hd:" optname; do
  case "$optname" in
    "h")
      usage
    ;;
    "d")
      export DROPBOX_DEST_PATH="${OPTARG}"
    ;;
    *)
      usage
    ;;
  esac
done
# Remove the opts from the $@ array so I can focus on Args
shift $((OPTIND -1))
# Now, the argument passed after options is the first argument $1

# Check if local folder path is provided
if [ -z "$1" ]; then
  echo
  echo "Please provide source path to local filesystem"
  usage
  exit 1
else
  export SOURCE_LOCAL_PATH="$1"
fi

# Check if dbxcli is accessible
if [ -z "$(dbxcli version 2>/dev/null)" ]; then 
  echo "There's no dbxcli in the PATH or it's not accessible"
fi

# echo "SOURCE_LOCAL_PATH: $SOURCE_LOCAL_PATH"
# echo "DROPBOX_DEST_PATH: $DROPBOX_DEST_PATH"

cd "$(dirname $SOURCE_LOCAL_PATH)"

find "$(basename "$SOURCE_LOCAL_PATH")" -exec bash -c '
    if [ -d "{}" ]; then 
        echo "Create new directory in $DROPBOX_DEST_PATH: {}" 
        dbxcli mkdir "$DROPBOX_DEST_PATH/{}"
    else 
        echo "Upload a file to $DROPBOX_DEST_PATH: {}" 
        dbxcli put "{}" "$DROPBOX_DEST_PATH/{}"
    fi' \
\;