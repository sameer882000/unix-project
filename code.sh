#!/bin/bash

Red="\e[1;31m"
NC="\E[0;0m"
echo -e "${Red}Welcome to 'User Password Change Monitoring' Project${NC}"

today_date="$(date | awk '{print $2$3$4}')"
echo "Today's date is $today_date"
today_date_seconds=`date --date=$today_date +%s`
echo $today_date_seconds

for account in $(awk -F':' '{print $1}' /etc/passwd)
do
	expires_string="$(sudo chage -l "$account" | grep 'Password expires' | awk '{print $4, $5, $6}')"
	changed_date="$(sudo chage -l "$account" | grep 'Last password change' | awk '{print $5, $6, $7}')"
	echo -e "ACCOUNT: $account ,\\t\\t	PASSWORD EXPIRES ON: $expires_string,\\t	PASSWORD CHANGED ON: $changed_date" >> user.txt
	if [ "$account" = "sameer.882000" ] || [ "$account" = "sameer.sinha" ]
	then
		echo
		echo "For $account expiry date is $expires_string"
		expiry_day="$(sudo chage -l "$account" | grep 'Password expires' | awk '{print $5}')"
		echo $expiry_day
		expiry_day=${expiry_day:0:-1}
		echo $expiry_day
		expiry_month_year="$(sudo chage -l "$account" | grep 'Password expires' | awk '{print $4$6}')"
		echo $expiry_month_year
		complete_expiry_date=$expiry_day$expiry_month_year
		echo $complete_expiry_date
		expiry_date_seconds=`date --date=$complete_expiry_date +%s`
		echo $expiry_date_seconds
		days_left=`expr $(($expiry_date_seconds - $today_date_seconds)) / 86400`
		echo $days_left

		if [ "$days_left" -lt 5 ]
		then
			echo -e "Alert!!\nOnly $days_left days is/are left for the password to be expired.\nIt is strongly recommended to change your password before the expiry date $expires_string." | mail -s "Warning: Password expires in $days_left days" "$account"@gmail.com
		else
			echo "Password expiry date for the user $account is $expires_string." | mail -s "Weekly Reminder" "$account"@gmail.com
		fi
	fi
done
