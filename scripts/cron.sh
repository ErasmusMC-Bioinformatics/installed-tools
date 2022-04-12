#!/bin/bash
# Fetch latest code
git fetch origin
git reset --hard origin/main

# Update submodules
git submodule sync
git submodule update --init --recursive

# Dependencies
if [[ ! -d ~/.cache/tools-venv ]] ; then
	virtualenv ~/.cache/tools-venv
fi
. ~/.cache/tools-venv/bin/activate
pip install -r requirements.txt

# "fix them"
make fix

# Apply the changes
make install GALAXY_SERVER=http://bioinf-galaxy.erasmusmc.nl/ GALAXY_API_KEY=$GALAXY_ADMIN_API_KEY

# Install workflows
find . -name '*.ga' -exec workflow-install -g http://bioinf-galaxy.erasmusmc.nl/ -a $GALAXY_ADMIN_API_KEY -w '{}' \;

# Reload the toolbox a couple times.
curl -X PUT http://bioinf-galaxy.erasmusmc.nl/api/configuration/toolbox -H "x-api-key: $GALAXY_ADMIN_API_KEY"
sleep 2
curl -X PUT http://bioinf-galaxy.erasmusmc.nl/api/configuration/toolbox -H "x-api-key: $GALAXY_ADMIN_API_KEY"
sleep 2
curl -X PUT http://bioinf-galaxy.erasmusmc.nl/api/configuration/toolbox -H "x-api-key: $GALAXY_ADMIN_API_KEY"
