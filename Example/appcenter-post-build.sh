#!/usr/bin/env bash

# CONSTANTS
MFZ_PROJ_NAME="MyFiziqTurnkey"
MFZ_APPCENTER_NAME="myfiziq-ios-sdk-turnkey"

# Prepare for AWS upload of the fat framework file.
pip install awscli
brew install infer
APP_VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "Pods/Target Support Files/${MFZ_PROJ_NAME}/${MFZ_PROJ_NAME}-Info.plist")

# need to run tests again to collect coverage reports. Cannot find them after AppCenter build
# xcodebuild -workspace "${MFZ_PROJ_NAME}.xcworkspace" -scheme "${APPCENTER_XCODE_SCHEME}" -destination 'platform=iOS Simulator,name=iPhone 8' test -enableCodeCoverage YES | xcpretty --report html

# Upload coverage to Codevo.io - Pretend as Jenkins CI
## Try to find the location of the Coverage.profdata
# BUILD_SETTINGS=`xcodebuild -workspace ${MFZ_PROJ_NAME}.xcworkspace -scheme ${APPCENTER_XCODE_SCHEME} -sdk iphonesimulator -showBuildSettings`
# Project Temp Root ends up with /Build/Intermediates/
# PROJECT_TEMP_ROOT=$(echo "${BUILD_SETTINGS}" | grep -m1 PROJECT_TEMP_ROOT | cut -d= -f2 | xargs)
# PROFDATA=$(find "${PROJECT_TEMP_ROOT}/../" -name "Coverage.profdata")
# if [[ -z $PROFDATA ]]; then
# 	echo "ERROR: Unable to find Coverage.profdata. Be sure to execute tests before running this script."
# else
#     cp "${PROFDATA}" ./
#     export JENKINS_URL="https://appcenter.ms/orgs/MyFiziq/apps/${MFZ_APPCENTER_NAME}"
#     export GIT_BRANCH=${APPCENTER_BRANCH}
#     export GIT_COMMIT=`git rev-parse HEAD`
#     export BUILD_NUMBER=${APPCENTER_BUILD_ID}
#     export BUILD_URL="https://appcenter.ms/orgs/MyFiziq/apps/${MFZ_APPCENTER_NAME}/build/branches/${APPCENTER_BRANCH}/builds/${APPCENTER_BUILD_ID}"
#     bash <(curl -s https://codecov.io/bash) -B ${APPCENTER_BRANCH} -t ${VAR_SDK_CODECOV} -b ${APPCENTER_BUILD_ID}
# fi

# Run static code analysis
# xcodebuild -workspace "${MFZ_PROJ_NAME}.xcworkspace" -scheme "${APPCENTER_XCODE_SCHEME}" -configuration Release -sdk iphonesimulator clean build | tee xcodebuild.log
# xcpretty -r json-compilation-database -o compile_commands.json < xcodebuild.log > /dev/null
# infer run --skip-analysis-in-path Pods --skip-analysis-in-path Submodules --clang-compilation-db-files-escaped compile_commands.json
# tar czvf "${MFZ_PROJ_NAME}.${APP_VERSION}.infer.tgz" "infer-out"
# aws s3 cp "${MFZ_PROJ_NAME}.${APP_VERSION}.infer.tgz" "${AWS_BUILDS_BUCKET_URI}/${MFZ_PROJ_NAME}/${APP_VERSION}/${APPCENTER_BUILD_ID}/${MFZ_PROJ_NAME}.${APP_VERSION}.infer.tgz"
# aws s3 cp "infer-out/bugs.txt" "${AWS_BUILDS_BUCKET_URI}/${MFZ_PROJ_NAME}/${APP_VERSION}/${APPCENTER_BUILD_ID}/${MFZ_PROJ_NAME}.${APP_VERSION}.infer.txt"
# sed -n '/Summary of the reports/,$p' infer-out/bugs.txt > infer.txt

# Run Docs generator tool, Jazzy, and upload to S3
bundle install
bundle exec jazzy
# cp build/reports/tests.html docs
# cp infer.txt docs
aws s3 sync "docs" "${AWS_DOCS_BUCKET_URI}/${MFZ_PROJ_NAME}/${APPCENTER_BRANCH}/"
