#!/bin/bash
#generating gitlab mirror urls
gitlab -c <path>/.python-gitlab.cfg  -o json -f projects group get --id <id> | jq '.projects[]._links.self' >>gitlab_projects
cut -d "\"" -f2  gitlab_projects >gitlab_project
cat gitlab_project  | while read line; do echo ${line}/remote_mirrors/ >>gitlab_projects_urls; done

#generating bitbucket repoo urls for setting mirroring
gitlab -c <path>/.python-gitlab.cfg  -o json -f projects group get --id <id> | jq '.projects[]|.http_url_to_repo' >>repo
cut -d "/" -f 5 repo |cut -d "\"" -f 1 >git_name
cat git_name | awk '{print tolower($0)}' >repo_git
cat repo_git  | while read line; do echo https://<bitbucket username>:<bitbucket app password>@bitbucket.org/<workspace>/${line} >>repo_url; done

#setting up mirroing
while read -u 3 -r file1 && read -u 4 -r file2; do
  gitlab_url=$(echo $file1)
  bitbucket_url=$(echo $file2)
  echo $bitbucket_url >>urls
  echo $gitlab_url >>urls
  curl --request POST --data "mirror=true" --data "enabled=true" --data  "url=${bitbucket_url}"  --header "PRIVATE-TOKEN: <bitbucket token>" ${gitlab_url}
done 3<gitlab_projects_urls 4<repo_url
