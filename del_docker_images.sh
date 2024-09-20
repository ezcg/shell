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
      docker rmi ${id}
      printf "\n\n"
    fi
  fi
done
