#!/bin/bash
#
# motd
#
# Fancy motd status inspired
# by /r/unixporn
#
# (c) 2018 Daniel Jankowski
# (c) 2020 Mauro A. Meloni


# import the utils module
source modules/utils.bash


# print packages that need to be updated for
# arch based systems with pacman
print_updates_arch() {
    # get the update count with counting lines of the
    # packages that needs updtes from pacman
    local update_count=$( pacman -Qu | wc -l )

    # print the module headline
    printf "Pacman Updates\n"

    # if there are updates
    if [[ "$update_count" != 0 ]]; then
        # print and indented list of the updates
        print_indented pacman -Qu
    else
        # if there are not updates, print it either
        printf "  No updates available\n"
    fi
}


# print packages that need to be updated for
# debian based systems with apt
print_updates_debian() {
    # get the update count with counting lines of the
    # packages that needs updtes from pacman
    local update_count=$( apt list --upgradable 2>/dev/null | tail -n "+2" | wc -l )

    # print the module headline
    printf "Debian/Ubuntu Updates\n"

    # if there are updates
    if [[ "$update_count" != 0 ]]; then
        # print and indented list of the updates
        print_indented apt list --upgradable 2>/dev/null | tail -n "+2"
    else
        # if there are not updates, print it either
        printf "  No updates available\n"
    fi
}


# print packages that needs an update
# using each distribution's package manager
print_updates() {
    # TODO: except Debian's, these checks are bogus;
    #       please update them accordingly

    # check using standard files
    test -x /etc/debian_version && print_updates_debian
    test -x /etc/ubuntu_version && print_updates_debian
    test -x /etc/arch_version && print_updates_arch
    return   # skip next checks

    # check using lsb_release
    local vendor = $( lsb_release -i | cur -d: )
    case "$vendor" in
    Debian) print_updates_debian ;;
    Ubuntu) print_updates_debian ;;
    Arch) print_updates_arch ;;
    esac
}
