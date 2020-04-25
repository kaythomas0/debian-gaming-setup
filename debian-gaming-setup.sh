#!/bin/bash
echo Let\'s get all the tools you need to start gaming on debian.
debian_version=$(cat /etc/debian_version)
if [[ $debian_version == *"10"* ]]
then
    debian_version="buster"
fi
echo It looks like your version of Debian is $debian_version. Is that correct [y/n]?
read version_confirmation
if [ $version_confirmation = "n" ] || [ $version_confirmation = "no" ]
then
    echo 'Are you running [s]table (buster), [t]esting (bullseye), or [u]nstable (sid)?'
    read version_input
    if [ $version_input = "s" ]
    then
        debian_version="buster"
    elif [ $version_input = "t" ] || [ $version_input = "u" ]
    then
        debian_version="bullseye/sid"
    else
        echo "Invalid command. Exiting..."
        exit 1
    fi
    echo Okay, you are running $debian_version
fi
echo 'Are you running on an [n]vidia, [a]md, or [i]ntel graphics card?'
read gpu
if [ $gpu = "n" ]
then
    gpu="Nvidia"
elif [ $gpu = "a" ]
then
    gpu="AMD"
elif [ $gpu = "i" ]
then
    gpu="Intel"
else
    echo "Invalid command. Exiting..."
    exit 1
fi