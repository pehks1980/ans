#!/bin/bash

text="Hello, my email is user@example.com."

# Regex pattern with a capturing group for the email
regex="([a-zA-Z0-9._%+-]+)@([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})"

if [[ $text =~ $regex ]]; then
  echo "Full match: ${BASH_REMATCH[0]}"
  echo "Captured acct: ${BASH_REMATCH[1]}"
  echo "domain name:: ${BASH_REMATCH[2]} "
else
  echo "No match found."
fi
