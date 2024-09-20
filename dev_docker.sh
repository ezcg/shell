#!/usr/bin/env bash

printf "\n\n\n=======================================\n\n\n"

if [ "$(whoami)" != "root" ] ; then
    printf "\n\nYou must run this as root. "
    echo "You are running this script as: " $(whoami)
    printf "\n\n"
    exit 1
fi

#check if build exists, if not, create, check if build is running, if not start, if running, offer to enter

dockerDirectory=$(pwd | grep "docker")
if [[ -z "$dockerDirectory" ]];then
    printf "\nYou must be in the  m2m-launch-api/docker directory when running this script.\n"
    #printf "\nSet a symlink if need be: ln -s /PATH/TO/YOUR/LOCAL/m2m-launch-api /var/app/m2m-launch-api\n\n"
    exit 0
fi

# default response to prompts is 'n'
default="n"

#check if image exists, build if it doesn't
image=$(docker image ls | grep m2m-launch-api)
if [[ -z "$image" ]]; then
    printf "\n\nDid not find a image named m2m-launch-api.\n\n"
else
    printf "\n\n"
    docker image ls | grep "REPOSITORY.*SIZE"
    printf "$image\n\n"
    read -p "Image named m2m-launch-api already exists. Remove it? (You can rebuild in the next step) [y/N]: " remove
    if [[ "$remove" = "y" ]];then

        # get image id
        id=$(echo "${image}" | awk '{print $3}')

        # check if container is using image
        in_use=$(docker container ls | grep "m2m-launch-api")
        if [[ ! -z "$in_use" ]]; then
            printf "\n\n"
            read -p "Image m2m-launch-api $id is being used by a container. Stop container and remove image? [y/n]: " stopcontainer
            if [[ "$stopcontainer" == "y" ]]; then
                container_id=$(docker container ls | awk '{print $1}')
                printf "\n\nStopping container id $container_id\n\n"
                docker container stop ${container_id}
            fi
        fi
        printf "\n\nRemoving image m2m-launch-api $id\n\n"
        response=$(docker rmi -f "${id}")
        if [[ "$response" == *"is being used by running container"* ]]; then
            docker rmi -f "${id}"
        fi
    fi
fi

if [[ -z "$image" ]]; then
    printf "\n\n"
    read -p "Would you like to build the docker image m2m-launch-api? [y/n]: " build
    if [[ "$build" = "y" ]]; then
        docker build -t m2m-launch-api .
    else
        printf "\n\nCannot proceed without a docker image\n\n"
        exit 0
    fi
fi

printf "\n\ndocker image built\n\n"
docker image ls | grep "m2m-launch-api"

printf "\n\nNext steps, enabling instance of m2m-launch-api...\n\n"

IS_CORRECT="n"
while [[ $IS_CORRECT == "n" ]]; do
    read -p "Type your first and last name, all lowercase, no spaces and alpha characters only (eg. bartsimpson): " username
    printf "\n"
	read -p "You entered '${username}'. Is that correct? [y/N]" IS_CORRECT
    IS_CORRECT=${IS_CORRECT:-$default}
done

dockerinstance="m2m-launch-api_${username}"
isRunning=$(docker container ls | grep "$dockerinstance")
if [[ -n "$isRunning" ]]; then
    printf "\n${dockerinstance} is enabled\n"
    printf "\n$isRunning\n\n"
else

    PATH_ON_HOST="$(pwd -P)/../"
    printf "\npath on host: $PATH_ON_HOST\n"
    printf "\npath in docker: /var/app/m2m-launch-api\n"
	EXPOSE_PORT=4009
    printf "\nEnabling '${dockerinstance}' on port ${EXPOSE_PORT}\n"
    docker run -e IS_DOCKER=1 -e APPLICATION_ENV=docker --rm -d --privileged=true -v "${PATH_ON_HOST}":/var/app/m2m-launch-api -t -p "${EXPOSE_PORT}":80 --name ${dockerinstance} m2m-launch-api

    printf "\nEnvironment variables IS_DOCKER set to 1 and APPLICATION_ENV set to 'docker'\n\n"

    #printf "\nRunning initdev.sh\n"
    #docker exec "$dockerinstance" /bin/bash -c "bash /var/www/html/initdev.sh"
    #printf "\ninitdev.sh executed\n"

    read -p "Start ${dockerinstance} in detached mode (runs in the background) [y/n]?" startdetached
    startdetached=${startdetached:-y}
    if [[ "$startdetached" = "y" ]]; then
        printf "\nStarting in detached mode\n"
        docker exec -it --detach "$dockerinstance" /bin/bash
    fi

fi

printf "\n\n"
docker exec "$dockerinstance" /bin/bash -c "cat /etc/os-release"
printf "\n\n"

# node modules are installed via the Dockerfile
read -p "Enter the package.json command to run (eg. npm run developer) or hit enter to skip:" npmcmd
if [[ -z "$npmcmd" ]];then
    printf "\nSkipping npm run\n"
else
    printf "\nRunning: $npmcmd\n"
    docker exec "$dockerinstance" /bin/bash -c "${npmcmd}"
    printf "\n$npmcmd executed\n"
fi

printf "\nIf this is your desktop, you can access docker from your desktop browser by using this ip :\n"
ip=$(docker exec "$dockerinstance" /bin/bash -c "ip a | grep -Po -m 2 'inet \K[^/]+' | tail -n1")
printf "$ip\n"
printf "\nYou can set it to a name in /etc/hosts on linux or Windows host file.\neg.: $ip dockerlocal-m2m-launch-api.inmarket.com\nCall dockerlocal-m2m-launch-api.inmarket.com in browser.\n\n"

read -p "Enter docker container ${dockerinstance} [n]?" enter
enter=${enter:-n}
if [[ "$enter" = "y" ]]; then
    printf "\nEntering...\n\n"
    docker exec -it "$dockerinstance" /bin/bash
else
    printf "\nNot entering docker container ${dockerinstance}\n\n"
fi

#printf "\nDocker setup done. Start docker manually to use.\n"
# comment
