#!/bin/bash

imageStr=$(docker images)
readarray -t imageArr <<<"$imageStr"

i=0
default="n"
for value in "${imageArr[@]}"
do
  ((i++))
  if [ $i -ge 2 ]; then
    echo "$i $value"
#    id=$(echo "$value" | awk '{print $1}'
    id=$(echo "$value" | awk '{print $3}')

    printf "\n"
    read -p "Delete [y/N]: " remove
    if [ "$remove" = "y" ]; then
      printf "\n\ndeleting $id"
      r=$(docker rmi ${id})
      echo "${r}"
      printf "\n\n"
      if [[ $r == *"stopped container"* ]]; then
        read -p "Delete the stopped container [y/N]: " delete
        if [ "$delete" = "y" ]; then
          cid=$(echo "$r" | grep -o "stopped container .*$")
          printf "\n\n"
          echo "Deleting stopped container ${cid}"
          printf "\n\n"
          docker rm "${cid}"
          printf "\n\n"
          echo "Trying to delete ${id} again"
          printf "\n\n"
          docker rmi "${id}"
        fi
      fi

    fi
  fi
done
