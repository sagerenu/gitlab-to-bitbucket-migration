#This is to create same repo name from gitlab to bitbucket
#Ist download Gitlab VLI from internet to your system 
#Setup app password in Bitbucket as the UI password are not supported by it anymore.
#Replac workspace with your workspace.
#enter the project key in which you want to add repo.If want to add in default remove the project key part.
#Valla you are good to go.
#!/bin/bash
gitlab -c <path>/.python-gitlab.cfg  -o json -f projects group get --id <id> | jq '.projects[]|.http_url_to_repo' >repo_name
cut -d "/" -f 6 repo_name |cut -d "." -f 1 >repo_names
cat repo_names | awk '{print tolower($0)}' >bitbucket_name
while read -u 3 -r file1 ; do
name=$(echo $file1)
curl -X POST -v -u <bitbuckeyusername>:<app passowrd> "https://api.bitbucket.org/2.0/repositories/<workspace>/${name}" -H "Content-Type: application/json" -d '{"scm": "git", "is_private": "true", "fork_policy": "no_public_forks","project": {"key": "'<key>'"}}'
done 3<bitbucket_name
