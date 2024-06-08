#!/bin/bash
title="literotica downloader"
prompt="Pick an option:"
options=("Series" "Page")
dir_root="$HOME/decode/literotica"
log_file="$HOME/.tmp/literotica-zenity.log"
regex='(https?|ftp|file)://[-[:alnum:]\+&@#/%?=~_|!:,.;]*[-[:alnum:]\+&@#/%=~_|]'
series_function() {
        url_value=$(zenity --entry \
                --width=800 \
                --title="enter the series page url" \
                --text="" \
                --entry-text "")
        echo "series url: $url_value" >> $log_file
        if [[ $url_value =~ $regex ]]
	then 
    		wget $url_value -q -E -O $HOME/.tmp/dirfile.txt
		dir_default=$(cat $HOME/.tmp/dirfile.txt | grep -oE '<h1 class="j_bm headline">.*</h1>'\
                     | sed 's/<h1 class="j_bm headline">//' | sed 's/<\/h1>//' | sed -e 's/\(.*\)/\L\1/' | sed -e "s/ /-/g")
    		echo "$dir_default" > $HOME/.tmp/decode.txt
    		dir_default=$(perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' $HOME/.tmp/decode.txt)
                story_name=$(echo "Story name: $dir_default" >> $log_file)
                dir_value=$(zenity --entry \
                        --title="enter directory" \
                        --text="" \
                        --entry-text "$dir_default")
                echo "Directory: $dir_value" >> $log_file
                dt=$(date '+%d/%m/%Y %H:%M:%S');
                echo "*** series scraping start: $dt ***" >> $log_file
                cd $dir_root
        	rm -r $dir_value
        	mkdir $dir_value
        	cd $dir_value
                echo "current location: $PWD" >> $log_file
        	lynx -dump -listonly $url_value | grep -i "www.literotica.com/s/$story_name" > .links.txt
        	sed -i 's/.* //g' .links.txt
        	file_count=$(wc -l < .links.txt)
        	echo "file count: $file_count" >> $log_file
        	for i in $(seq 1 $file_count);
		do
			file_name=$(sed "${i}q;d" .links.txt)
    			lynx -dump -listonly $file_name | grep -i "?page=" >> .pages.txt
        		sed -i '$s/?page=.*//' .pages.txt 
    			page_count=$(wc -l < .pages.txt)
    			num=$(($page_count -1))
    			last_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num=$(($page_count -2))
    			early_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num1=$(($early_page +1))
    			num2=$(($last_page -1))
    			if [[$num2 -gt 1]]
    			then
    				for t in $(seq $num1 $num2);
				do
                                	echo "adding missing page $t to .pages.txt" >> $log_file
    					echo "$file_name?page=$t" >> .pages.txt
				done
			fi
		done
	else
                echo "Link not valid - exiting" >> $log_file
                zenity --warning --text="$url_value is not a valid url."
    		return 1
	fi
	sed -i 's/.* //g' .pages.txt
        echo "*** retrieving files ***" >> $log_file
        cat .pages.txt >> $log_file
        wget -i .pages.txt -q -E
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo "*** page scraping end: $dt ***" >> $log_file
        return 0
}
page_function() {
        url_value=$(zenity --entry \
        	--width=800 \
 		--title="enter the page url" \
		--text="" \
		--entry-text "")
        echo "page url: $url_value" >> $log_file
        if [[ $url_value =~ $regex ]]
	then 
    		wget $url_value -q -E -O $HOME/.tmp/dirfile.txt
    		dir_default=$(cat $HOME/.tmp/dirfile.txt | grep -oE '<h1 class="j_bm headline j_eQ">.*</h1>' \
                    | sed 's/<h1 class="j_bm headline j_eQ">//' | sed 's/<\/h1>//' | sed -e 's/\(.*\)/\L\1/' | sed -e "s/ /-/g")
    		echo "$dir_default" > $HOME/.tmp/decode.txt
    		dir_default=$(perl -Mopen=locale -MHTML::Entities -pe '$_ = decode_entities($_)' $HOME/.tmp/decode.txt)
                story_name=$(echo "Story name: $dir_default" >> $log_file)
		dir_value=$(zenity --entry \
	 		--title="enter directory" \
			--text="" \
			--entry-text "$dir_default")
        	echo "Directory: $dir_value" >> $log_file
                dt=$(date '+%d/%m/%Y %H:%M:%S');
                echo "*** page scraping start: $dt ***" >> $log_file
                cd $dir_root
        	rm -r $dir_value
        	mkdir $dir_value
        	cd $dir_value
                echo "current location: $PWD" >> $log_file
        	lynx -dump -listonly $url_value | grep -i "?page=" >> .pages.txt
        	sed -i '$s/?page=.*//' .pages.txt
        	page_count=$(wc -l < .pages.txt)
        	if [[$page_count -eq 0]]
        	then
        		echo "0. $url_value" > .pages.txt
        	fi
    		num=$(($page_count -1))
    		if [[ $num -gt 2 ]]
		then 
			page_count=$(wc -l < .pages.txt)
    			num=$(($page_count -1))
    			last_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num=$(($page_count -2))
    			early_page=$(sed -n "${num}s/^.*=//p" .pages.txt)
    			num1=$(($early_page +1))
    			num2=$(($last_page -1))
    			for t in $(seq $num1 $num2);
			do
				echo "adding missing page $t to .pages.txt" >> $log_file
    				echo "$url_value?page=$t" >> .pages.txt
			done 
		fi
	else
    		echo "Link not valid - exiting" >> $log_file
		zenity --warning --text="$url_value is not a valid url."
    		return 1
	fi
	sed -i 's/.* //g' .pages.txt
	echo "*** retrieving files ***" >> $log_file
	cat .pages.txt >> $log_file
	wget -i .pages.txt -q -E
        dt=$(date '+%d/%m/%Y %H:%M:%S');
        echo "*** page scraping end: $dt ***" >> $log_file
        return 0
}
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "*** start: $dt ***" > $log_file
while true; do
	cd $HOME
        echo "current location: $PWD" >> $log_file
	while opt=$(zenity --title="$title" --ok-label "Go" --cancel-label "Done" --text="$prompt" --list  --column="Options"  "${options[@]}");
	do
    	select=""
    	case "$opt" in
    		"${options[0]}" ) select="Series"; series_function; break;;
    		"${options[1]}" ) select="Page"; page_function; break;;
 		*) zenity --error --text="what?" && continue
 	esac
	done > /dev/null 2>&1
	if [ -z "${opt}" ]
	then
		break
	fi
done
dt=$(date '+%d/%m/%Y %H:%M:%S');
echo "*** end $dt ***" >> $log_file
zenity --text-info --width=600 --height=600 --title="literotica downloader log" --filename=$log_file

