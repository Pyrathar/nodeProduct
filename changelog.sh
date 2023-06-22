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

# Prompt the user for input
echo "Write a very descriptive message to be included in the changelog:"

# Capture user input and store it in a variable
changelog_message=$1
choice=$2

# Get the current branch name
branch=$(git rev-parse --abbrev-ref HEAD)

#Grab the ticket number
kyc_number=$(echo "$branch" | grep -oEi 'KYC-[[:digit:]]+')

if [ -z "$kyc_number" ]; then
  echo "No KYC number in your branch"
  exit 1
fi

#Upper case it justin case (yes pun intented)
uppercase_kyc_number=$(echo "$kyc_number" | tr '[:lower:]' '[:upper:]')

#Creates the final message
formated_message="- [$uppercase_kyc_number](https://linear.app/penneo/issue/$uppercase_kyc_number) [$choice] $changelog_message" 

IFS=$'\n'
# Prompt the user with a multi-line message
read -r -d '' prompt_message << EOM
Alright writing!
$formated_message 
Does this look OK? (Enter to accept):
EOM

# Display the prompt message and read the response
read -p $'\n'"$prompt_message" response

# Check the response
if [[ "$response" =~ ^[Yy]$|^$ ]]; then
    write_in_changelog "$formated_message";
else
    echo "Stopping."
    exit 0
fi
