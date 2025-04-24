#!/bin/bash

if [ $# -ne 1 ]; then
    echo "[!] Usage: $0 domain.com"
    exit 1
fi

domain=$1

echo -e "DOMAIN\t\tEMAIL\t\t\tCREATED\t\tEXPIRES\t\tAGE(DAYS)\tALERT"

extract_field() {
    echo "$1" | grep -i "$2" | head -n1 | cut -d':' -f2- | sed 's/^[ \t]*//'
}

whois_output=$(whois "$domain")

email=$(extract_field "$whois_output" "Registrant Email")
[ -z "$email" ] && email=$(extract_field "$whois_output" "Admin Email")

created=$(extract_field "$whois_output" "Creation Date")
expires=$(extract_field "$whois_output" "Expiration Date")

created_ts=$(date -d "$created" +%s 2>/dev/null)
expires_ts=$(date -d "$expires" +%s 2>/dev/null)
now_ts=$(date +%s)

if [ -n "$created_ts" ] && [ -n "$expires_ts" ]; then
    age=$(( (now_ts - created_ts) / 86400 ))
    days_left=$(( (expires_ts - now_ts) / 86400 ))

    if [ "$days_left" -lt 30 ]; then
        alert="EXPIRES IN $days_left DAYS"
    else
        alert="-"
    fi
else
    age="N/A"
    alert="DATE ERROR"
fi

printf "%-16s %-24s %-12s %-12s %-10s %-s\n" \
    "$domain" "$email" "$(echo $created | cut -d'T' -f1)" \
    "$(echo $expires | cut -d'T' -f1)" "$age" "$alert"
