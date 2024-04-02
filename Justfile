# list all available commands
default:
  just --list

# run gcloud login
login:
  gcloud auth login
  gcloud auth application-default login

# switch active gcloud project
switch-project project:
	gcloud config set project {{project}} 

# export firestore data
# first, switch project to the project you want to export data from
# second, drop the "indexed_event_gram" collection
# third, export the db to a new cloud bucket
# fourth, download the exported data
# AND download all the files in the default app engine bucket
# compress both
export-db project:
    just switch-project {{project}}
    sed -i "s|REPLACE_PROJECT_ID|{{project}}|g" {{justfile_directory()}}/.firebaserc
    firebase firestore:delete -r -f /indexed_event_gram
    gsutil rm -r gs://{{project}}.appspot.com/db-export/
    gcloud firestore export gs://{{project}}.appspot.com/db-export/
    sleep 5
    mkdir -p {{justfile_directory()}}/{{project}}
    gsutil -m cp -r gs://{{project}}.appspot.com/ {{justfile_directory()}}/{{project}}/
    tar -czvf {{justfile_directory()}}/{{project}}.tar.gz {{justfile_directory()}}/{{project}}/
    sed -i "s|{{project}}|REPLACE_PROJECT_ID|g" {{justfile_directory()}}/.firebaserc
