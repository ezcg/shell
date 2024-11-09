#!/bin/bash

# Get a formatted list of docker images
imageStr=$(docker images --format "{{.Repository}} {{.Tag}} {{.ID}}")

# Read the images into an array
readarray -t imageArr <<<"$imageStr"
i=0

for value in "${imageArr[@]}"; do
  ((i++))
  if [ $i -ge 2 ]; then
    echo "$i $value"
    id=$(echo "$value" | awk '{print $3}')
    printf "\n"
    read -p "Delete [y/N]: " remove
    if [ "$remove" = "y" ]; then
      printf "\n\n"
      echo "deleting ${id}"
      printf "\n\nexecuting docker rmi command\n\n"
      r=$(docker rmi "${id}")
      printf "\n\nexecuted\n\n"
      echo "result from docker rmi: ${r}"
      printf "\n\n"
      if [[ "${r}" == *"stopped container"* ]]; then
        read -p "Delete the stopped container [y/N]: " delete
        if [ "${delete}" = "y" ]; then
          cid=$(echo "${r}" | grep -o "stopped container [[:alnum:]]*" | awk '{print $3}')
          printf "\n\n"
          echo "Deleting stopped container ${cid}"
          printf "\n\n"
          docker rm "${cid}"
          printf "\n\n"
          echo "Trying to delete ${id} again"
          printf "\n\n"
          docker rmi "${id}"
        fi
      else
        echo "Did not find the string: 'stopped container' in ${r}"
      fi
    fi
  fi
done
