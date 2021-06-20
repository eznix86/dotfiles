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

if [[ $1 =~ ^(-r)$ ]]; then
    MODE="R"
elif [[ $1 =~ ^(-b)$ ]]; then
    MODE="B"
fi

###################
# BACKUP-RESTORE SYSTEM
###################

function restore() {
    target_directory=$1
    file=$2
    namespace=$3

    original_file=$(echo $target_directory/$file)
    backup_namespace=$(echo $BACKUP_DIRECTORY/$namespace)
    backup_location=$(echo $backup_namespace/$file)

    echo $original_file
    echo $backup_namespace
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
    namespace=$3

    original_file=$(echo $target_directory/$file)
    backup_namespace=$(echo $BACKUP_DIRECTORY/$namespace)
    backup_location=$(echo $backup_namespace/$file)
    mkdir -p $(dirname $backup_location)
    cp -r $original_file $backup_location
    printf "file '%s' OK\n" $original_file;

}

function find_files_in_namespace() {

    namespace_directory=$1
    namespace_name=$2


    target_directory=$(echo $namespace_directory | jq -r ".value.target")
    files_list=$(echo $namespace_directory | jq -r ".value?.files")

    if [[ "null" == "$files_list" ]]; then
        case $MODE in
        'R')
            restore $target_directory "." $namespace_name
            ;;
        'B')
            backup $target_directory "." $namespace_name
            ;;
        esac
        return 1        
    fi

    for file in `echo $files_list | jq -r ".[]"`
    do

        case $MODE in
        'R')
            restore $target_directory $file $namespace_name
            ;;
        'B')
            backup $target_directory $file $namespace_name
            ;;
        esac
    done
}

function prompt() {
    printf "Hi %s, \n" $1

    printf "Do you want to restore or backup [nothing] ? (r/b/n): " 
    read action

    while ! [[ "$action" =~ ^(r|R|b|B|n|N)$ ]]; do
        printf "Do you want to restore or backup [nothing] ? (r/b/n): " 
        read action
    done

    MODE=${action^^}

    printf "\n" 

}


function find_namespace() {
    for namespace_directory in `echo $BACKUP_JSON | jq -c ". | to_entries |.[]"`
    do
        key=$(echo $namespace_directory | jq -r ".key")

        case $MODE in
            'R')
                printf "\nRestore '%s'\n\n" $key
                ;;
            'B')
                printf "\nBack up '%s'\n\n" $key
                ;;
        esac

        find_files_in_namespace $namespace_directory $key
    done
}

### run here

if [[ "$MODE" =~ ^(N)$ ]]; then
    prompt $USER
fi


if [[ "$MODE" =~ ^(N)$ ]]; then
    printf "\n## No backup/restore performed ##\n"
    exit 1
fi

if [[ "$MODE" =~ ^(B)$ ]]; then
    rm -rf $BACKUP_DIRECTORY
fi


find_namespace

