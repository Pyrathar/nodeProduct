#!/bin/bash

# first parametter is the message
write_in_changelog() {

# Get the current date
current_date=$(date +"%d-%m-%Y")

# Specify the string to insert
string_to_insert=$1

# Determine the script directory
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Specify the path to your changelog file relative to the script directory
file_path="$script_dir/CHANGELOG.md"

# Determine the insertion point based on the current date
insertion_point=""
if grep -q "## $current_date" "$file_path"; then
    insertion_point="## $current_date"
elif grep -q "## Unreleased" "$file_path"; then
    insertion_point="## Unreleased"
fi

dateToFind="## $current_date"
# Create a temporary file to store the modified contents
temp_file=$(mktemp)
if [ "$insertion_point" == "$dateToFind" ]; then
    awk -v insert="$string_to_insert" -v dateToFind="$dateToFind" '
    BEGIN {
      found_date = 0
      found_changed = 0
    }
    {
      if (found_date && found_changed) {
        print insert
        found_date = 0
        found_changed = 0
      }
      if ($0 == dateToFind) {
        found_date = 1
      }
      if ($0 == "### Changed") {
        found_changed = 1
      }
      print
    }
' "$file_path" > "$temp_file"
mv "$temp_file" "$file_path"

else
    awk -v insert="$string_to_insert" -v date="$dateToFind" '
      BEGIN {
        found_unreleased = 0
    }
    {
        if (found_unreleased == 1) {
            print
            print date
            print "### Changed"
            print  insert
            found_unreleased = 2
        }
        if ($0 == "## Unreleased") {
            found_unreleased = 1
        }
        print
    }
' "$file_path" > temp_file

# Replace the original file with the modified contents
mv temp_file "$file_path"
fi
}

# Capture input and store it in a variable
changelog_message=$1

# Extract the first character before the first hyphen
first_character=$(echo "$changelog_message" | awk -F'-' '{print $1}')

# Replace all hyphens with spaces, starting from the second occurrence
replaced_string=$(echo "$changelog_message" | sed 's/-/ /' | sed 's/-/ /g')

finalChangelogMessage="$first_character$replaced_string"

# Get the current branch name
branch=$(git rev-parse --abbrev-ref HEAD)

#Grab the ticket number
kyc_number=$(echo "$branch" | grep -oEi 'KYC-[[:digit:]]+')

if [ -z "$kyc_number" ]; then
  kyc_number="Hotfix"
fi

#Upper case it justin case (yes pun intented)
uppercase_kyc_number=$(echo "$kyc_number" | tr '[:lower:]' '[:upper:]')

#Creates the final message
if [[ "$kyc_number" == "Hotfix" ]]; then
    formated_message="- [$uppercase_kyc_number](https://linear.app/penneo/issue/$uppercase_kyc_number) $finalChangelogMessage" 
else
    formated_message="- [$kyc_number] $finalChangelogMessage" 
fi
formated_message="- [$uppercase_kyc_number](https://linear.app/penneo/issue/$uppercase_kyc_number) $finalChangelogMessage" 
write_in_changelog "$formated_message";
