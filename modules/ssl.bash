#!/bin/bash
#
# motd
#
# Fancy motd status inspired
# by /r/unixporn
#
# (c) 2018 Daniel Jankowski


# print the status of ssl ceritificates for
# different domains and perform an expiration
# check
print_ssl_expire_date() {
    # print the module title
    printf "SSL Certificates:\n"

    # get the current unix-timestamp to check later
    # if the certificates are valid or expired
    local current_unixtime=$( date +"%s" )

    # iterate through all domains configured in
    # DOMAINS-array
    for domain in ${DOMAINS[@]}; do

        # use proxy environment variable, if defined
        local OPTIONAL_PROXY=""
        if [[ "$no_proxy" != *"$domain"* ]] && [[ "$NO_PROXY" != *"$domain"* ]]; then
            if [ -n "$https_proxy" ]; then
                OPTIONAL_PROXY="${https_proxy/http:\/\//}"
                OPTIONAL_PROXY="-proxy ${OPTIONAL_PROXY/\//}"
            elif [ -n "$HTTPS_PROXY" ]; then
                OPTIONAL_PROXY="${HTTPS_PROXY/http:\/\//}"
                OPTIONAL_PROXY="-proxy ${OPTIONAL_PROXY/\//}"
            fi
        fi

        # get the expiration date from the domain certificates
        # with openssl
        local expire_date=$(
            openssl s_client $OPTIONAL_PROXY \
                -connect "$domain:443" \
                -servername "$domain" \
                < /dev/null 2>/dev/null \
                | openssl x509 -noout -enddate \
                | grep -oP '(?<=notAfter=).*'
        )

        # convert the expiration date to a unix timestamp
        local expire_date_unixtime=$( date -d "$expire_date" +"%s" )

        # define some colors
        #TODO: config file
        local color_valid='\e[32m'
        local color_invalid='\e[38m'
        local color_reset='\e[0m'

        # check if the certificate is expired
        if [[ "$current_unixtime" -ge $expire_date_unixtime ]]; then
            # print red and with triangle if its expired
            printf "  ${color_invalid}▲${color_reset} $domain\t\tvalid until $expire_date\n"
        else
            # print green and a circle if the certificate is valid
            printf "  ${color_valid}● ${color_reset}$domain\t\tvalid until $expire_date\n"
        fi
    done
}
