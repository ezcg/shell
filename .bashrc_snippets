if [[ $- == *i* ]]; then
    green=$(tput bold)$(tput setaf 6)
    red=$(tput bold)$(tput setaf 1)
    normal=$(tput sgr0)
    headline=$(tput bold)
fi

#matt       97347  4.3  1.0 2726692 348740 ?      Sl   11:21   0:06 /usr/bin/vlc --started-from-file /home/matt/Downloads/Camera/PXL_20201022_031855418.mp4

function killvlc {
    for pid in $(ps aux | grep vlc | grep -Po "^matt[\s]+\K[0-9]+"); do echo "$pid" && sudo kill -9 "$pid"; done
}

#
#for file in $(find . -type f -name "*\.log"); do echo "$file" | grep -i "fatal\|error\|fail\|creating" $file | grep -v "inflating"; echo $file; done
#for file in $(find . -type f -name "*\.log"); do > "$file"; done


function gitarchiveezcgbe {
    cd /home/matt/PhpstormProjects/ezcgbe
    git archive -v -o ../laravel-default.zip --format=zip HEAD
}

function zipezcgbe {
    cd /home/matt/PhpstormProjects/ezcgbe
    zip ../laravel-default.zip -r * .[^.]* -x "vendor/*" ".git/*" "docker*"
    zip ../nflbe.zip -r * .[^.]* -x "vendor/*" ".git/*" "docker*"
    zip ../nflbe.zip -r * .[^.]* -x ".idea/*" "storage/logs/.*" "vendor/*" ".git/*" "docker*" "storage/framework/views/*.php" "storage/debugbar/*" "storage/framework/sessions/*"

}

function getpublicip {
    printf "\n"
    curl -s checkip.dyndns.org | sed -e 's/.*Current IP Address: //' -e 's/<.*$//'
    printf "\n"
}

function listallusers {
    printf "\n"
	awk -F'[/:]' '{if ($3 >= 1000 && $3 != 65534) print $1}' /etc/passwd
    printf "\n"
}

# show the name of the git repo you're on
function gitrepo {
	basename `git rev-parse --show-toplevel`
}

# not tried yet
function killnode {
	netstat -anp 2> /dev/null |
	grep :$@ |
	egrep -o "[0-9]+/node" |
	cut -d'/' -f1 |
	xargs kill;
}

function killnode2 {
    pid=$(netstat -ntlp | grep -Po "LISTEN[^0-9]*\K[0-9]*")
    if [[ ! -z "$pid" ]];then
        printf "\nKilling pid $pid\n"
        kill -9 "$pid"
    else
        printf "\nDid not find a pid to kill\n"
    fi
}

function goreal {
	REALPATH=$(pwd -P)
	printf "\n$REALPATH\n\n"
	cd "$REALPATH"
}

function listbigfiles {
	find / -type f -size +20000k -exec ls -lh {} \; 2> /dev/null | awk '{ print $5 ": " $NF }' | sort -nrk 1,1
}

function whatsmyip {
	printf "\n\n"
	curl ifconfig.me
	printf "\n\n"
}

#https://unix.stackexchange.com/a/29811
alias su='su -l'

function dockernetwork {
    docker inspect $1 -f "{{json .NetworkSettings.Networks }}"
}

function getdockernames {
    docker ps --format {{.Names}}
}

function dockerips {
  v=$(docker ps --format "{{.Names}}") && for name in $v; do docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $name; echo $name; done
}

function dockerclean {
    docker rm -v $(docker ps --filter status=exited -q 2>/dev/null) 2>/dev/null
    docker rmi $(docker images --filter dangling=true -q 2>/dev/null) 2>/dev/null
}

function dockerip {
	name=$1
	if [[ -z "$name" ]]; then
    		read -p "Docker container name:" name
	fi
	docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$name"

}

alias dockerprune=' \
    docker container prune -f ; \
    docker image prune -f ; \
    docker network prune -f ; \
    docker volume prune -f '

function dockerlaravellogs {
    curdate=`date +"%Y-%m-%d"`
    printf "\nSearching loglines with $curdate\n"
    v=$(docker ps --format "{{.Names}}") && for name in $v; do printf "\n\n\n$name $curdate\n" && docker exec -it $name bash -c "cat /var/app/current/storage/logs/laravel.log | grep -i '$curdate'"; done
}

function dockerlaravellogsempty {
    v=$(docker ps --format "{{.Names}}") && for name in $v; do printf "\n\n\nEmptying logs for $name\n" && docker exec -it $name bash -c "> /var/app/current/storage/logs/laravel.log"; done
}

function dockerapachelogs {
    curdate=`date +"%Y-%m-%d"` && v=$(docker ps --format "{{.Names}}") && for name in $v; do printf "\n\n\n$name $curdate\n" && docker exec -it $name bash -c "tail -1000 /var/log/apache2/${name}_error.log | grep -i '$curdate'"; done
}

function dockerapachelogsempty {
    v=$(docker ps --format "{{.Names}}") && for name in $v; do printf "\n\n\nEmptying logs for $name\n" && docker exec -it $name bash -c ">  /var/log/apache2/${name}_error.log"; done
}

function portsopen {
    sudo netstat -ntlp | grep LISTEN
}
function listnode {
    #ps ax | grep "app.js" | fgrep -v grep | awk '{ print $1 }'
    sudo ps ax | grep "app.js" | fgrep -v grep
}
function killport {
    printf "\n\nports open\n"
    portsopen
    port=$1
    printf "\n\nKilling port $port\n\n"
    sudo kill -9 $(sudo netstat -ntlp | grep LISTEN | grep ::"$port" | grep -oP "LISTEN      \K[0-9]+")
    printf "\n\nports open\n"
    portsopen
}

function getpidwithport {
	port=$1
	#printf "\nsudo netstat -ntlp | grep LISTEN | grep \"::${port}\" | grep -oP \"LISTEN      \K[0-9]+\"\n"
	sudo netstat -ntlp | grep LISTEN | grep ::$port | grep -oP "LISTEN      \K[0-9]+"
}

function macosgetpidwithport {
	lsof -nP -i4TCP:$1 | grep LISTEN
}

function whatisrunningonport {
	port=$1
	printf "\nport $port\n"
	printf "lsof -i :${port}\n"
	sudo lsof -i ":${port}"
	printf "\ngetpidwithport $port\n"
	pid=$(getpidwithport "$port")
	printf "\npid found $pid\n"
	sudo ps -fp "$pid"
}

function findPackage {
	dpkg -l | grep $1
}

function findownedby {
    owned_by=$1
    if [[ -z "$owned_by" ]]; then
        printf "\nFirst argument should be name of owner of files being searched for.\n"
        return
    fi
    find . -user "$owned_by"
}

function findnotownedby {
    not_owned_by=$1
    if [[ -z "$not_owned_by" ]]; then
        printf "\nFirst argument should be name of owner of files NOT being searched for.\n"
        return
    fi
    find . ! -user "$not_owned_by"
}

function setownedby {

    owned_by=$1
    if [[ -z "$owned_by" ]]; then
        printf "\nFirst argument should be name of user to set to owner of files.\n\n"
        return
    fi
    read -p "Set all files in $PWD and below to be owned by ${owned_by}? [y/n] " action
    if [[ "$action" = "y" ]]; then
        printf "\n\nSetting all files in $PWD recursively to be owned by ${owned_by} \n\n"
        # set all files to owned_by that are not already owned by user
        find . ! -user "$owned_by" -exec sudo chown "$owned_by":"$owned_by" {} \; -print
    else
        printf "\nNot doing anything.\n"
    fi

}

function findbrokensymlinks {
    printf "\n\n"
    find -L . -name . -o -type d -prune -o -type l -exec printf {} \;
    printf "\n\n"
}

function removebrokensymlinks {
    find -L . -name . -o -type d -prune -o -type l -exec rm {} +
}

function showmemoryuse {

    printf "\n\nps aux --sort=-%mem | awk 'NR<=10{print $0}'\n\n"
    ps aux --sort=-%mem | awk 'NR<=10{print $0}'
    printf "\n\ntop o %MEM -d 10 -b|grep "load average" -A 15\n\n"
    top o %MEM -d 10 -b|grep "load average" -A 15

}

function findinfile {
    read -p "File name (a * will be added to end of filename): " filename
    read -p "String to search through filenames like ${filename}* in current directory: " str
    find . -type f -name "${filename}*" -exec grep -PoH ".{25}${str}.{25}" {} \;
}

function gitinit {
	eval `ssh-agent`
	ssh-add ~/.ssh/id_rsa
}

# https://avilpage.com/2014/04/access-clipboard-from-terminal-in.html
# copy the contents like this: cat fruits.txt | c
alias c='xclip -selection clipboard'
alias v='xclip -o'

