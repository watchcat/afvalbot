#!/bin/sh

echo ">>>>  Starting afvalbot <<<<"
# use while loop to check if elasticsearch is running
while true
do
    ./afvalbot
    echo "Hey, I'm crashed - check your code!"
done
