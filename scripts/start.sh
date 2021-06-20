#!/bin/bash

###################
# CONSTANTS
###################

DIRECTORY="$HOME/.dotfiles"

BACKUP_DIRECTORY="$DIRECTORY/backups"

BACKUP_JSON="$(yq eval 'del(.base*)' -j $DIRECTORY/backup.yaml)"

# MODE R for restore
# MODE B for backup
MODE="N";


###################
# BACKUP-RESTORE SYSTEM
###################

function restore() {
    target_directory=$1
    file=$2
    group=$3

    original_file=$(echo $target_directory/$file)
    namespace=$(echo $BACKUP_DIRECTORY/$group)
    backup_location=$(echo $namespace/$file)

    echo $original_file
    echo $namespace
    echo $backup_location
    echo $(dirname $original_file)

    if [[ -d $backup_location ]]; then
        cp -r $backup_location $(dirname $original_file)
    elif [[ -f $backup_location ]]; then
        cp -r $backup_location $original_file
    fi
    
    printf "file '%s' OK\n" $original_file;

}

function backup() {
    target_directory=$1
    file=$2
    group=$3

    original_file=$(echo $target_directory/$file)
    namespace=$(echo $BACKUP_DIRECTORY/$group)
    backup_location=$(echo $namespace/$file)
    mkdir -p $(dirname $backup_location)
    cp -r $original_file $backup_location
    printf "file '%s' OK\n" $original_file;

}

function find_files_in_group() {

    group_directory=$1
    group_name=$2


    target_directory=$(echo $group_directory | jq -r ".value.target")
    for file in `echo $group_directory | jq -r ".value.files[]"`
    do

        case $MODE in
        'R')
            restore $target_directory $file $group_name
            ;;
        'B')
            backup $target_directory $file $group_name
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

        find_files_in_group $group_directory $key
    done
}

### run here

prompt $USER

if [[ "$MODE" =~ ^(N)$ ]]; then
    printf "\n## No backup/restore performed ##\n"
    exit 1
fi

if [[ "$MODE" =~ ^(B)$ ]]; then
    rm -rf $BACKUP_DIRECTORY
fi


find_group

