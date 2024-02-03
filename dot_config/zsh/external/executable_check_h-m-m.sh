#!/bin/bash

# Get the date of the latest commit from the GitHub API
GITHUB_DATE=$(curl -s "https://api.github.com/repos/nadrad/h-m-m/commits?per_page=1" | jq -r ".[0].commit.author.date" | cut -d 'T' -f1)
echo "timestamp on repository $GITHUB_DATE"

# Get the installation date of the local file
LOCAL_DATE=$(stat -c %w /usr/local/bin/h-m-m | awk '{print$1}')
echo "local file last mod $LOCAL_DATE"

# Compare the dates
if [ "$GITHUB_DATE" \> "$LOCAL_DATE" ]; then
    echo "There is probably an update of the h-m-m script available."
else
    echo "Your local copy of the h-m-m script is up to date."
fi

