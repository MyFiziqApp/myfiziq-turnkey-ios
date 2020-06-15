#!/usr/bin/env bash

# CONSTANTS
MFZ_PROJ_NAME="MyFiziqTurnkey"
MFZ_APPCENTER_NAME="myfiziq-ios-sdk-turnkey"

git config credential.helper 'cache --timeout=3600'

cat <<EOF > ~/.netrc
machine git-codecommit.ap-southeast-1.amazonaws.com
login ${CODE_COMMIT_USER}
password ${CODE_COMMIT_PASS}
EOF

chmod 600 ~/.netrc

pod repo add myfiziq-private https://git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/myfiziq-sdk-podrepo
