#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

# Build the project.
hugo -t hugo-redlounge

# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push


#Change directory to public
cd public

# Add changes to git
git add -A

# Commit changes.
msg="rebuilding site `date`"
git commit -m "$msg"

# Push source and build repos.
git push