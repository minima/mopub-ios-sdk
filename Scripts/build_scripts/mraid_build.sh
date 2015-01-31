#!/bin/sh

#  mraid_build.sh
#  MoPubSDK
#
#  This script will copy mraid.js out of a shared repo and place it into MRAID.bundle.  It will also insert a comment in the copied version
#  mentioning that the copied version must not be modified as all changes will be lost when the project is built.
#
#  Copyright (c) 2014 MoPub. All rights reserved.

copyMRAIDToResources() {
    # The comment that will appear at the top of the copied mraid.js file.
    MRAID_JS_COMMENT="/*"$'\n'"Do not modify this version of the file.  It will be copied over when any of the project's targets are built."$'\n'"If you wish to modify mraid.js, modify the version located at mopub-sdk-common/mraid/mraid.js."$'\n'"*/"$'\n'

    # Store the file's content in a variable so we can prepend the comment to it and direct the output to a file.
    MRAID_JS_FILE_CONTENT=`cat "$1/mopub-sdk-common/mraid/mraid.js"`

    # Insert the comment before the mraid.js content and output it to
    echo -n "${MRAID_JS_COMMENT}${MRAID_JS_FILE_CONTENT}" > "$1/MoPubSDK/Resources/MRAID.bundle/mraid.js"
}
