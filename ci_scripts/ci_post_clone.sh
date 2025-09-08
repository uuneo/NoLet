#!/bin/sh

#  ci_post_clone.sh
#  pushme
#
#  Created by lynn on 2025/9/7.
#  

git clone https://"$GITHUB_NAME":"$GITHUB_TOKEN"@github.com/"$GITHUB_NAME"/"$GITHUB_PROJECT_SAFE".git

if [ -d "$GITHUB_PROJECT_SAFE" ]; then
    echo "Clone 成功 ✅"
else
    echo "Clone Fail ❌"
    exit 1
fi

APP_FILE_PATH="$CI_PRIMARY_REPOSITORY_PATH"/Publics/Domap.swift

rm -rf "$APP_FILE_PATH"

mv "$GITHUB_PROJECT_SAFE"/Domap.swift "$APP_FILE_PATH"

rm -rf $GITHUB_PROJECT_SAFE

if [ -f "$APP_FILE_PATH" ]; then
    echo "MV Success ✅"
else
    echo "MV Fail ❌"
    exit 1
fi

