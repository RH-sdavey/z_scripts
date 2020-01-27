#!/bin/bash

hash_input=$1
curl_out_file=/tmp/curl_out_file_delete_me
curl_out_file2=/tmp/curl_out_file_delete_me2

print_help() {
  printf "\nUSAGE:\n"
  printf "$0\t\t\t  :You will be asked for the hash id in script\n"
  printf "$0 <commit hash id>\t  \n\n"
  printf "HELP:\n$0 --help\t\t  :Show this help text and exit\n\n"
  exit 0
}

if [[ "$#" -eq 0 ]] ; then
	read -p "Which commit hash do you want info on?: " hash_input
else
	for arg in "$@" ; do
		if [[ $arg == "help" ]] || [[ $arg == "-h" ]] || [[ $arg == "--help" ]] ; then
			print_help
		fi
	done
fi

_(){ sed "s/^/\t\t/" <($*); }

do_curl_from_acc() {
  curl -s <<MY ACC URL HERE>>/${hash_input} > $curl_out_file   # change this url to the actual one
}

get_author_from_curl() {
  grep -A1 "<dt>Author</dt>" $curl_out_file |
   tail -1 | sed -e 's/^[[:space:]]*//' |
    sed -e 's/^<dd>*//' |
     sed -e 's+</dd>$*++'
}

get_commit_message_from_curl() {
  grep -A1 "<dt>Commit Message</dt>" $curl_out_file |
   tail -1 | sed -e 's/^[[:space:]]*//' |
    sed -e 's/^<dd>*//' |
     sed -e 's+</dd>$*++'
}

get_commit_repo_from_curl() {
  grep -A1 "<dt>Repository</dt>" $curl_out_file  |
   tail -1 |
    sed -e 's/^[[:space:]]*//' |
     sed -e 's/^<dd>*//' |
      sed -e 's+</dd>$*++'
}

get_date_from_curl() {
  grep -A1 "<dt>Date</dt>"  $curl_out_file  |
   tail -1 |
    sed -e 's/^[[:space:]]*//' |
     sed -e 's/^<dd>*//' |
      sed -e 's+</dd>$*++'
}

get_all_build_info() {
   cat $curl_out_file |
    sed -n '/tbody/,/tbody>/p' |
     sed -e 's/^[[:space:]]*//' |
      sed -e 's/^<dd>*//' |
       sed -e 's+</dd>$*++' |
        sed -e 's/^<tbody>*//' |
         sed -e 's/^tbody>*//'
}
get_each_row_from_get_all_build_info() {    # what a mess, it works and I dont want to change it
  _ get_all_build_info |
    sed -n '/tr/,/tr>/p;' |
       sed -n '/td/,/td>/p;' > $curl_out_file2

  read -d '' -r -a lines < $curl_out_file2

  for i in $(seq 0 4 36); do
    x=$(( i + 1 ))
    printf "${lines[$i]}  :  ${lines[$x]}\n" |
     sed -e 's/<td>/\t/g' |
      sed -e 's+</td>++g' |
      sed -e 's+^[:blank:]+\t+g'
  done
}

do_curl_from_acc
printf "\nAuthor of the commit:\t  $(get_author_from_curl)\n"
printf "Commit Message Title:\t  $(get_commit_message_from_curl)\n"
printf "Commit Repository:\t  $(get_commit_repo_from_curl)\n"
printf "Date Commited:\t\t  $(get_date_from_curl)\n\n"
printf "All build info I can parse:\n$(get_each_row_from_get_all_build_info | column -t)\n\n"
printf "[27.01 patrik] You should use the value from this line to close your Jira\n"
printf "$(get_each_row_from_get_all_build_info | grep 'hds-command' | column -t)\n"
