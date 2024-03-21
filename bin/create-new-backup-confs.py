#!/usr/bin/env python3
######################################################
# End Point Backup server create script
# Setup base directories and conf files for new servers
# Take the manual make steps out of the equation
#
# 2018-11-02 - Initial work by Ian Neilsen <ian@endpointdev.com>
# 2024-03-19 - Updates by Josh Ausborne <jausborne@endpointdev.com>
#              - Update for Python3
#              - Organize into functions
#              - Parameterize things a bit
######################################################

import os
import shutil

# Set variables
backup_root = "/backup"
backup_conf = f"{backup_root}/conf/"
backup_rsync = f"{backup_root}/rsync/"
mysql_path = "var/backup/mysql/"
postgres_path = "var/lib/postgresql/backups/"

def check_for_conf_directory(server):
    # Check if conf directory already exists
    if os.path.isdir(backup_conf + server) == False:
        create_conf_directory(server)
    else:
        if os.path.isdir(backup_conf + server) == True:
            print("The conf directory already exists.")
        exit(0)

def create_conf_directory(server):
    # Create server conf directory
    try:
        os.mkdir(backup_conf + server)
    except OSError:
        print(f"Creation of the directory {backup_conf + server} failed")
    else:
        print(f"Created the directory {backup_conf + server}")

def check_for_rsync_directory(server):
    # check if rsync directory already exists
    if os.path.isdir(backup_rsync + server) == False:
        create_rsync_directory(server)
    else:
        if os.path.isdir(backup_rsync + server) == True:
            print("The rsync directory already exists.")
        exit(0)

def create_rsync_directory(server):
    # Create server rsync directory
    try:
        os.mkdir(backup_rsync + server)
    except OSError:
        print(f"Creation of the directory {backup_rsync + server} failed")
    else:
        print(f"Created the directory {backup_rsync + server}")

def add_backup_config(server,domain):
    # Create backup.conf
    try:
        file = open(f"{backup_conf}/{server}/backup.conf" , "a+")
        file.write(f"host={server}\n")
        file.write(f"domain={domain}\n")
        file.write("snapshots=7\n")
        file.close()
    except OSError:
        print(f"Creation of {backup_conf + server} failed")
    else:
        print(f"Created the config file at {backup_conf + server}/backup.conf")

def add_test_config(server):
    # Create tests.conf
    try:
        file = open(f"{backup_conf}/{server}/tests.conf" , "a+")
        file.write("common_tests\n")
        file.close()
    except OSError:
        print(f"Creation of tests conf {backup_conf + server} failed")
    else:
        print(f"Created the test config file at {backup_conf + server}/tests.conf\n")
        add_mysql_tests(server)
        add_postgres_tests(server)

def add_mysql_tests(server):
    # Ask if MySQL tests are needed
    is_mysql = input("Is MySQL installed on server: Enter y/n ")
    # Create MySQL tests
    if is_mysql == "y":
        file = open(f"{backup_conf}/{server}/tests.conf", "a+")
        file.write(f"mysql_backups {mysql_path}\n")
        file.close()
        print("MySQL tests added\n")
    else:
        print("No MySQL tests included\n")

def add_postgres_tests(server):
    # Ask if PostgreSQL tests are needed
    is_postgres = input("Is PostgreSQL installed on server: Enter y/n ")
    # Create PostgreSQL tests
    if is_postgres == "y":
        postgres_path_yn = input(f"Is {postgres_path} correct?: Enter y/n ")
        if postgres_path_yn == "y":
            file = open(f"{backup_conf}/{server}/tests.conf", "a+")
            file.write(f"postgres_backups {pg_path}\n")
            file.close()
            print("PostgreSQL tests added\n")
        else:
            postgres_path_input = input(f"Enter path to postgres backups: ")
            if postgres_path_input != "":
                file = open(f"{backup_conf}/{server}/tests.conf", "a+")
                file.write(f"postgres_backups {postgres_path_input}\n")
                file.close()
                print("PostgreSQL tests added\n")
            else:
                print("PostgreSQL backup path is not set. Using default instead.")
                set_postgres_path(server,postgres_path)
    else:
        print("No Postgresql tests include\n")

def add_daily_files(server):
    # Create basic include and exclude files
    exclude_file = f"{backup_root}/bin/daily-exclude"
    include_file = f"{backup_root}/bin/daily-include"
    daily_files = [exclude_file,include_file]
    for daily_file in daily_files:
        destination = f"{backup_root}/conf/{server}/"
        shutil.copy(daily_file, destination)

def create_directories(server):
    check_for_conf_directory(server)
    check_for_rsync_directory(server)

def add_configurations(server,domain):
    add_backup_config(server,domain)
    add_test_config(server)
    add_daily_files(server)

def main():
    server = input("What is the server's short name? (i.e. short names server103): ")
    if ' ' in server:
        print("No spaces allowed in server name")
        exit(0)
    domain = input("What is the server's domain name? (i.e. mydomain.com): ")
    if ' ' in domain:
        print("No spaces allowed in domain name")
        exit(0)
    print()
    create_directories(server)
    add_configurations(server,domain)

if __name__ == "__main__":
    main()
