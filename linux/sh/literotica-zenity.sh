#!/bin/bash
title="literotica downloader"
prompt="Pick an option:"
options=("Series" "Page")
series_function() {
	regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
	read -p "series url: " url_value
        echo "***"; echo $url_value;
        if [[ $url_value =~ $regex ]]
	then 
    		echo "*** Link is valid, continuing ***"
    		wget $url_value -q -E -O .tmp/dirfile.txt
		dir_default=$(cat .tmp/dirfile.txt | grep -oE '<h1 class="j_bm headline">.*</h1>' | sed 's/<h1 class="j_bm headline">//' | sed 's/<\/h1>//' | sed -e 's/\(.*\)/\L\1/' | sed -e "s/ /-/g")
    		echo "$dir_default" > .tmp/decode.txt
    		dir_default=$(perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' .tmp/decode.txt)
		read -e -p "directory: " -i "$dir_default" dir_value
    		#read -p "directory: " dir_value
        	echo "***"; echo $dir_value
        	cd decode/literotica
        	mkdir $dir_value
        	cd $dir_value
        	lynx -dump -listonly $url_value | grep -i "$dir_value" > .links.txt
        	sed -i 's/.* //g' .links.txt
        	file_count=$(wc -l < .links.txt)
        	for i in $(seq 1 $file_count);
		do
			file_name=$(sed "${i}q;d" .links.txt)
    			echo "processing file: $file_name"
    			lynx -dump -listonly $file_name | grep -i "?page=" >> .pages.txt
        		sed -i '$s/?page=.*//' .pages.txt 
    			page_count=$(wc -l < .pages.txt)
    			num=$(($page_count -1))
    			last_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num=$(($page_count -2))
    			early_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num1=$(($early_page +1))
    			num2=$(($last_page -1))
    			for t in $(seq $num1 $num2);
			do
				echo "adding file: $file_name?page=$t"
    				echo "$file_name?page=$t" >> .pages.txt
			done    	
		done
	else
    		echo "Link not valid"
    		return 1
	fi
	sed -i 's/.* //g' .pages.txt
	echo "*** retrieving files ***"
	cat .pages.txt
	wget -i .pages.txt -q -E
	echo "*** done ***"
        return 0
}
page_function() {
	regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
	read -p "page url: " url_value
        echo "***"; echo $url_value;
        if [[ $url_value =~ $regex ]]
	then 
    		echo "*** Link is valid, continuing ***"
    		wget $url_value -q -E -O .tmp/dirfile.txt
    		dir_default=$(cat .tmp/dirfile.txt | grep -oE '<h1 class="j_bm headline j_eQ">.*</h1>' | sed 's/<h1 class="j_bm headline j_eQ">//' | sed 's/<\/h1>//' | sed -e 's/\(.*\)/\L\1/' | sed -e "s/ /-/g")
    		echo "$dir_default" > .tmp/decode.txt
    		dir_default=$(perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' .tmp/decode.txt)
    		read -e -p "directory: " -i "$dir_default" dir_value
    		#read -p "directory: " dir_value
        	echo "***"; echo $dir_value
        	cd decode/literotica
        	mkdir $dir_value
        	cd $dir_value
        	echo "processing file: $url_value"
        	echo "0. $url_value" > .pages.txt
        	lynx -dump -listonly $url_value | grep -i "?page=" >> .pages.txt
        	sed -i '$s/?page=.*//' .pages.txt
        	page_count=$(wc -l < .pages.txt)
    		num=$(($page_count -1))
    		if [[ $num > 0 ]]
		then 
			sed -i '1d' .pages.txt
			page_count=$(wc -l < .pages.txt)
    			num=$(($page_count -1))
    			last_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num=$(($page_count -2))
    			early_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num1=$(($early_page +1))
    			num2=$(($last_page -1))
    			for t in $(seq $num1 $num2);
			do
				echo "adding file: $url_value?page=$t"
    				echo "$url_value?page=$t" >> .pages.txt
			done 
		fi
	else
    		echo "Link not valid"
    		return 1
	fi
	sed -i 's/.* //g' .pages.txt
	echo "*** retrieving files ***"
	cat .pages.txt
	wget -i .pages.txt -q -E
	echo "*** done ***"
        return 0
}
while true; do
	cd /home/jsmith
	while opt=$(zenity --title="$title" --ok-label "Go" --cancel-label "Done" --text="$prompt" --list  --column="Options"  "${options[@]}");
	do
    	select=""
    	case "$opt" in
    		"${options[0]}" ) select="Series"; series_function; break;;
    		"${options[1]}" ) select="Page"; page_function; break;;
 		*) zenity --error --text="it was a simple question?" && continue
 	esac
        if zenity --question --text=" $select" ; then break ;fi
	done > /dev/null 2>&1
	if [ -z "${opt}" ];
	then
		break
	fi
done
echo "done."
