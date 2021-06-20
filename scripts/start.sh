#!/bin/bash

###################
# CONSTANTS
###################

DIRECTORY="$HOME/.dotfiles"

BACKUP_DIRECTORY="$DIRECTORY/backups"

BACKUP_JSON="$(yq eval 'del(.base*)' -j $DIRECTORY/backup.yaml)"

# MODE R for restore
# MODE B for backup
MODE="n";


###################
# BACKUP-RESTORE SYSTEM
###################

function restore() {
    target_directory=$1
    file=$2

    original_file=$(echo $target_directory/$file)
    backup_file=$(echo $BACKUP_DIRECTORY/$file)
    echo "$backup_file"
    if [ -d $backup_file ]; then
        mkdir -p $original_file
    fi

    cp -r $backup_file $original_file

    printf "file '%s' OK\n" $original_file;

}

function backup() {
    target_directory=$1
    file=$2

    original_file=$(echo $target_directory/$file)
    backup_file=$(echo $BACKUP_DIRECTORY/$file)
    if [ -d $original_file ]; then
        mkdir -p $backup_file
    fi
    cp -r $original_file $backup_file
    printf "file '%s' OK\n" $original_file;

}

function find_files_in_group() {

    group_directory=$1

    target_directory=$(echo $group_directory | jq -r ".value.target")
    for file in `echo $group_directory | jq -r ".value.files[]"`
    do

        case $MODE in
        'R')
            restore $target_directory $file
            ;;
        'B')
            backup $target_directory $file
            ;;
        esac
    done
}

function prompt() {
    printf "Hi %s, \n" $1

    while ! [[ "$action" =~ ^(r|R|b|B|n|N)$ ]]; do
        printf "Do you want to restore or backup [nothing] ? (r/b/n): " 
        read action
    done

    MODE=${action^^}

    printf "\n" 

}


function find_group() {
    for group_directory in `echo $BACKUP_JSON | jq -c ". | to_entries |.[]"`
    do
        key=$(echo $group_directory | jq -r ".key")

        case $MODE in
            'R')
                printf "\nRestore '%s'\n\n" $key
                ;;
            'B')
                printf "\nBack up '%s'\n\n" $key
                ;;
        esac

        find_files_in_group $group_directory
    done
}

### run here

prompt $USER

if [[ "$MODE" =~ ^(N)$ ]]; then
    printf "\n## No backup/restore performed ##\n"
    exit 1
fi

find_group

