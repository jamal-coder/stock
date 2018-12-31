#!/bin/bash

#-----------------------------------------------------------------------
#	Script			: 	stock.sh
#	Version			: 	1 Alpha
#	Author			:	Jamal Khan
#	Date Started	:	30th December, 2018
#	Date Completed	:	1st January, 2019
#	Purpose			: 	This program will keep record of stock account.
#-----------------------------------------------------------------------

#--------------------- Variable Declaration Section ------------------------------
greenbold="\033[1;32m"
normal="\033[0m"
flashred="\033[5;31m"
FileName=.Stock.txt
exists="NO"
#--------------------- Functions Declaration Section -----------------------------
# logo function displays logo of the program for 5 seconds
function logo {
	clear
	if [[ -f /usr/bin/banner ]]; then
		echo -e $greenbold
		banner "STOCK A/C"
		echo -e $normal
		echo -e $flashred
		banner "Version 1 Beta"
		echo -e $normal
	else
		echo -e $greenbold" \n\t\t\tSTOCK ACCOUNT "$normal
		echo -e $flashred" \t\t\tVersion 1 Beta "$normal
	fi
	sleep 3
}
# Heading function displays heading according to Call
function Heading {
	clear
	echo -e $greenbold"\n\t\t$1 Menu\n"$normal
}

# Wait function create a pause of program
function Wait {
	echo -ne $greenbold"\n\t\tPress "$normal$flashred"<ENTER>"$normal$greenbold" to proceed.."$normal
	read dummy
}

# StockCode function ask user about stockcode
function StockCode {
	# Initializaing stockcode variable
	code=""
	# Restricting stockcode variable to at least 6 digits for similairty
	while [[ ! $code =~ [0-9]{6} ]]; do
		read -p "	Enter at least six digits long Stock Code : " code
	done
	echo $code
}

# Checking function search for availability of stockcode in database
function Checking {
	if [[ -f $FileName ]]; then
		grep $1 $FileName > /dev/null 
	fi
}

# Obtaining function search for items in database and return the value
function Obtaining {
	case $2 in
		1)
			item=$(grep $1 $FileName | awk -F ":" '{print $1}');;
		2)
			item=$(grep $1 $FileName | awk -F ":" '{print $2}');;
		3)	
			item=$(grep $1 $FileName | awk -F ":" '{print $3}');;
		4)
			item=$(grep $1 $FileName | awk -F ":" '{print $4}');;
	esac
	echo $item
}

# Updating funciton, updates the database file
function Updating {
	grep -v $1 $FileName > temp.txt
	echo "$1:$2:$3:$4" >> temp.txt
	sort temp.txt > $FileName
	rm temp.txt

	if [[ $4 -eq 0 ]]; then
		grep -v $1 $FileName > temp.txt
		cat temp.txt > $FileName
		rm temp.txt
	fi
}

#------------------------- Main Program Section ----------------------------------
logo
while true; do
	clear
	echo -e $greenbold"\n\t\t\tMain Menu"$normal
	echo -e "\n\t\t[1] Purchases of Stock"
	echo -e "\t\t[2] Sales of Stock"
	echo -e "\t\t[3] View Stock"
	echo -e "\t\t[4] Stock Account Help"
	echo -e "\t\t[5] Quit"
	echo -ne "\n\t\tSelect your choice [1-5] : "
	read choice
	echo $choice
	
	case $choice in
		1)
			while true; do
				# Calling Heading function with Purchases arguments
				Heading Purchases
				stockcode=$(StockCode)
				Checking "$stockcode"
				# if database file exists and exist status is Zero then activate if clause
				# otherwise else clause
				if [[ -f $FileName && $? -eq 0 ]]; then
					echo -e "\t------------------------------------------------------------"
					stockname=$(Obtaining $stockcode 2)
					stockrate=$(Obtaining $stockcode 3)
					stockqty=$(Obtaining $stockcode 4)
					echo -e "\tStock Name                                : $stockname"
					echo -e "\tExisting Stock Rate                       : $stockrate"
					echo -e "\tAvialable Stock Quantity                  : $stockqty"
					echo -e "\t------------------------------------------------------------"
					echo -ne "\n\tEnter Revised Rate of Stock               : "
					read stockrate
					echo -ne "\tEnter new purchased quantity              : "
					read newqty
					stockqty=$(( stockqty + newqty ))
				else
					echo -ne "\tNew Stock Name                            : "
					read stockname
					echo -ne "\tNew Stock Rate                            : "
					read stockrate
					echo -ne "\tNew Stock Quantity                        : "
					read stockqty
					echo -e "\t------------------------------------------------------------"
				fi
				clear
				Heading Purchases
				echo "-----------------------------------------------------------------"
				echo -e "\tStock Code     : $stockcode"
				echo -e "\tStock Name     : $stockname"
				echo -e "\tStock Rate     : $stockrate"
				echo -e "\tStock Quantity : $stockqty"
				echo "-----------------------------------------------------------------"
				echo -ne "\tDo you want to save this information [Yn]: "
				read choice
				if [[ $choice = [Yy] ]]; then
					echo -e $greenbold"\n\tSaving data into database..."$normal
					sleep 2
					# Transfer database to a temp file and then sort it and back stored in database
					if [[ -f $FileName ]]; then
						Updating "$stockcode" "$stockname" "$stockrate" "$stockqty"
					else
						echo "$stockcode:$stockname:$stockrate:$stockqty" >> $FileName
					fi
				fi
				# Asking for further data entry
				echo -ne "\n\tDo you want to enter more data in database [yN] : "
				read selection
				if [[ $selection = [Nn] ]]; then
					break
				fi
			done
			;;
		2)
			counter=0
			scode=()
			sname=()
			srate=()
			sqty=()
			stotal=()
			while true; do
				soldqty=0
				Heading Sales
				stockcode=$(StockCode)
				Checking "$stockcode" 

				if [[ -f $FileName && $? -eq 0 ]]; then
					echo -e $flashred$greenbold"\n\tAvialable Stock\n"$normal
					echo -e "\t--------------------------------------------------------------------------------"
					stockname=$(Obtaining $stockcode 2)
					stockrate=$(Obtaining $stockcode 3)
					stockqty=$(Obtaining $stockcode 4)
					echo -e "\tStock Name                                : $stockname"
					echo -e "\tStock Rate                                : $stockrate"
					echo -e "\tAvialable Stock Quantity                  : $stockqty"
					echo -e "\t--------------------------------------------------------------------------------"
					# Checks if user enter quantity more then available
					while true; do 
						echo -ne "\tQuantity sold                             : "
						read soldqty
						if [[ $soldqty -gt $stockqty ]]; then
							echo -e $flashred"\tWarning: "$normal$greenbold" Stock Limit is $stockqty"$normal
						else
							break
						fi
					done
					echo -e "\t--------------------------------------------------------------------------------"
					echo -e $greenbold"\tUpdating database..."$normal
					sleep 2
					echo -e "\t--------------------------------------------------------------------------------"
					# saving data into array for billing process
					scode[$counter]=$stockcode
					sname[$counter]=$stockname
					srate[$counter]=$stockrate
					sqty[$counter]=$soldqty
					stotal[$counter]=$(( stockrate * soldqty ))
					# updating stockqty
					stockqty=$(( stockqty - soldqty ))
					# Updating database file
					Updating "$stockcode" "$stockname" "$stockrate" "$stockqty"
					# Asking user for another entry
					echo -ne "\n\tDo you want another entry [yN]: "
					read choice
					if [[ $choice = [Nn] ]]; then
						break
					fi
				else
					echo -e $greenbold"\n\tStock not available\n"$normal
					echo -e "\tPlease check stock by using [3] View Stock item of Main Menu"
					echo -e "\tfor available stock and then use the appropriate stock code."
					echo -ne $greenbold"\n\tDo you want to try again [yN]: "$normal
					read choice
					if [[ $choice = [Nn] ]]; then
						break
					fi
				fi
				
				(( counter++ ))
			done
			# Billing of sales
			clear
			currentdate=$(date +"%d-%m-%Y")
			count=0
			grandtotal=0

			echo -e $greenbold"\n\t\t\t\t\tSales Bill"
			echo -e "Dated: $currentdate"$normal
			echo "--------------------------------------------------------------------------------------------------"
			printf "%-8s %-40s %-15s %-15s %-15s\n" "Sr#" "Item" "Rate" "Quantity" "Total"
			echo "--------------------------------------------------------------------------------------------------"
			while [[ $count -le $counter ]]; do
				printf "%-8d %-40s %-15d %-15d %-15d\n" "${scode[count]}" "${sname[$count]}" "${srate[$count]}" "${sqty[count]}" "${stotal[count]}"
				grandtotal=$(( grandtotal + stotal[count] ))
				(( count++ ))
			done
			echo "--------------------------------------------------------------------------------------------------"
			echo -e "\t\tGrand Total\t\t\t\t\t\t\t  $grandtotal"
			echo "--------------------------------------------------------------------------------------------------"
			Wait
			;;
		3)
			clear
			Heading "Available Stock"
			echo "--------------------------------------------------------------------------------------------------"
			printf "%-8s %-40s %-15s %-15s\n" "Code" "Item" "Rate" "Quantity"
			echo "--------------------------------------------------------------------------------------------------"
			echo -e $greenbold"\n\tCalculating database, please wait..."$normal
			sleep 2
			clear
			awk -F ":" '{printf "%-8s %-40s %-15s %-15s\n", $1, $2, $3, $4}' $FileName | less
			;;
		4)
			clear
			Heading "Help Menu"
			echo "--------------------------------------------------------------------------------------------------"
			cat <<- EndofText
			Project : Stock.sh
			Version : 1 Alpha
			Author	: Jamal Khan
			Licence : Freeware
			Purpose : To keep record of stock, while it can be updated by purchases and reduced by sales. 
			          The program will wipe out the stock entry when its quantity is reached to Zero. 
			          This way the life of program will not due to redundunt values in the database.
			Special : When user is asked through prompt there you will observe two options one in Upper Case 
			          and the The other in Lower Case. Upper Case is always special that means if you want 
			          to perform that task You should select the Upper case option, though you can select that 
			          option in lower case too. But that is mandatory to perform a specific task. However, 
			          lower case option don't need to be selected as it can be default even by pressing enter 
			          key on the keyboard will do that option.
			Example : Do you want to enter more data in database [yN] : 
			Details : In this example to avoid further data in the database N the upper case should be selected 
			          though even in the form of 'n' both means the same. But even if you press the 'Enter Key' 
			          the 'y' lower case option will be selected automatically.
			EndofText
			echo "--------------------------------------------------------------------------------------------------"
			Wait
			;;
		5)
			clear
			echo -e $greenbold"\n\n\t\t\tAllah Hafiz (Good Bye)\n\n"
			exit 0
			;;
	esac
done