#!/usr/bin/env bash
#
# a very simple shell script which sends pull requests to back github
# this script frees you from the webinterface
#
#
# Copyright (C) 2012 Marcos Diez < marcos AT unitron.com.br >
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

if [ -z "$1" ]
then
    echo "usage: $0 YOUR_BRANCH TARGET_REPO_OWNER [PULL_REQUEST_TITLE] [PULL_REQUEST_BODY] [TARGET_REPO_BRANCH]"
    echo "if not specified, TARGET_REPO_OWNER will be the default from GitHub"
    echo "if not specified, PULL_REQUEST_TITLE will be YOUR_BRANCH"
    echo "if not specified, PULL_REQUEST_BODY  will be blank"
    echo "if not specified, TARGET_REPO_BRANCH will be master"
    exit
fi

if [ -z "$5" ]
then
    TARGET_REPO_BRANCH="master"
else
    TARGET_REPO_BRANCH="$5"
fi

if [ -z "$4" ]
then
    PULL_REQUEST_BODY=""
else
    PULL_REQUEST_BODY="$4"
fi

if [ -z "$3" ]
then
    PULL_REQUEST_TITLE="$1"
else
    PULL_REQUEST_TITLE="$3"
fi


TARGET_REPO_OWNER=$2
YOUR_BRANCH=$1  # `git status |head -n 1  | cut -d" " -f4`

LOGIN=`git config --get remote.origin.url |cut -d ":" -f2 | cut -d "/" -f 1`
REPOSITORY=`git config --get remote.origin.url |cut -d ":" -f2 | cut -d "/" -f 2 | cut -d "." -f  1`
AUTH=$LOGIN

echo "LOGIN=${LOGIN}"
echo "REPOSITORY=${REPOSITORY}"
echo "TARGET_REPO_OWNER=${TARGET_REPO_OWNER}"
echo "TARGET_REPO_BRANCH=${TARGET_REPO_BRANCH}"
echo "YOUR_BRANCH=${YOUR_BRANCH}"
if [ -z "$2" ]
    then
    read -s -p "Enter your GitHub Password: " mypassword
    echo ""
    AUTH="${AUTH}:${mypassword}"
    TARGET_REPO_OWNER=`curl -u ${AUTH} "https://api.github.com/repos/${LOGIN}/${REPOSITORY}" | grep -A 50 "parent" | grep login | head -n 1 | cut -d'"' -f4`
    echo "TARGET_REPO_OWNER=${TARGET_REPO_OWNER}"
fi
curl -u ${AUTH} "https://api.github.com/repos/${TARGET_REPO_OWNER}/${REPOSITORY}/pulls" --data "{ \"title\":\"${PULL_REQUEST_TITLE}\" , \"body\":\"${PULL_REQUEST_BODY}\" , \"head\":\"${LOGIN}:${YOUR_BRANCH}\" , \"base\": \"${TARGET_REPO_BRANCH}\"  }"



