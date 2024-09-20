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
    name=$(echo "$value" | awk '{print $1}')
    tag=$(echo "$value" | awk '{print $2}')
    id=$(echo "$value" | awk '{print $3}')

    printf "\n"
    read -p "Untag [y/N]: " remove
    if [ "$remove" = "y" ]; then
      printf "\n\nuntagging ${name}:${tag}"
      docker rmi "${name}:${tag}"
      printf "\n\n"
    fi
  fi
done
