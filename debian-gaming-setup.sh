#!/bin/bash
echo 'This script will help you get all the tools you need to start gaming on debian.'
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
echo To get the best gaming performance you should install the latest graphics drivers.
if [ $gpu = "Nvidia" ]
then
    if [ $debian_version = "buster" ]
    then
        echo 'Since you are running stable, it is recommended that you use buster-backports to install your graphics drivers in order to get the latest versions.'
        echo 'Would you like to use buster-backports to install your graphics drivers [y/n]?'
        read use_backports
    fi
    echo 'In order to proceed with the installation of the necessary packages to update your graphics drivers, you need to allow non-free packages in your apt sources by doing the following:'
    if [ $use_backports = "y" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append the line:'
        echo 'deb http://deb.debian.org/debian buster-backports main contrib non-free'
    elif [ $debian_version = "buster" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append the line:'
        echo 'deb http://deb.debian.org/debian/ buster main contrib non-free'
    elif [ $debian_version = "bullseye/sid" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append this line if you are on testing:'
        echo 'deb http://deb.debian.org/debian/ bullseye main contrib non-free'
        echo 'Or this line if you are on sid:'
        echo 'deb http://deb.debian.org/debian/ sid main contrib non-free'
    fi
    echo 'Once you have modified your sources, you are ready to install the required graphics packages. Have you appended your apt source with non-free [y/n]?'
    read appended_apt_sources
    echo 'You should update apt now, would you like to do that now [y/n]?'
    read update_apt
    if [ $update_apt = "y" ]
    then
        apt update
    fi
    echo 'You should update your linux kernel headers before installing your graphics drivers, would you like to do that now [y/n]?'
    read update_kernel_headers
    if [ $update_kernel_headers = "y" ]
    then
        if [ $debian_version = "buster" ]
        then
            echo 'Are you using the linux kernel from buster-backports (by default, a standard installation of debian stable would not use the linux kernel from buster-backports) [y/n]?'
            read use_kernel_backports
        else
            use_kernel_backports="n"
        fi
        if [ $use_kernel_backports = "y" ]
        then
            apt-get install -t buster-backports linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//')
        else
            apt-get install linux-headers-$(uname -r|sed 's/[^-]*-[^-]*-//')
        fi
    fi
    echo 'The nvidia-detect package can be used to identify the GPU and required driver package. Would you like to install and run this package now [y/n]?'
    read install_nvidia_detect
    if [ $install_nvidia_detect = "y" ]
    then
        apt-get install nvidia-detect
        nvidia-detect
        echo "Did nvidia-detect recommend you install the [1]nvidia-driver, [2]nvidia-legacy-390xx-driver, or [3]nvidia-legacy-340xx-driver package?"
        read driver_package
    else
        echo "Would you like to install the [1]nvidia-driver, [2]nvidia-legacy-390xx-driver, or [3]nvidia-legacy-340xx-driver package?"
        read driver_package
    fi
    echo 'You should install the nvidia-driver package to update your graphics drivers, would you like to do that now [y/n]?'
    read install_nvidia_driver
    if [ $install_nvidia_driver = "y" ]
    then
        if [ $driver_package = "1" ]
        then
            if [ $use_backports = "y" ]
            then
                apt-get update
                apt-get install -t buster-backports nvidia-driver 
            else
                apt-get update
                apt-get install nvidia-driver
            fi
        elif [ $driver_package = "2" ]
        then
            apt-get update
            apt-get install nvidia-legacy-390xx-driver
        elif [ $driver_package = "3" ]
        then
            apt-get update
            apt-get install nvidia-legacy-340xx-driver
            echo 'You need to create an Xorg configuration file. This can be done automatically by this script, would you like to do that now [y/n]?'
            read create_xorg_conf
            if [ $create_xorg_conf = "y" ]
            then
                mkdir -p /etc/X11/xorg.conf.d
                echo -e 'Section "Device"\n\tIdentifier "My GPU"\n\tDriver "nvidia"\nEndSection' > /etc/X11/xorg.conf.d/20-nvidia.conf
            fi
        fi
    fi
fi
if [ $gpu = "AMD" ]
then
    echo 'In order to proceed with the installation of the necessary packages to update your graphics drivers, you need to allow non-free packages in your apt sources by doing the following:'
    if [ $debian_version = "buster" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append the line:'
        echo 'deb http://deb.debian.org/debian/ buster main contrib non-free'
    elif [ $debian_version = "bullseye/sid" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append this line if you are on testing:'
        echo 'deb http://deb.debian.org/debian/ bullseye main contrib non-free'
        echo 'Or this line if you are on sid:'
        echo 'deb http://deb.debian.org/debian/ sid main contrib non-free'
    fi
    echo 'Once you have modified your sources, you are ready to install the required graphics packages. Have you appended your apt source with non-free [y/n]?'
    read appended_apt_sources
    echo 'You should update apt now, would you like to do that now [y/n]?'
    read update_apt
    if [ $update_apt = "y" ]
    then
        apt-get update
    fi
    echo 'You are ready to install the non-free Linux firmware (required for the AMD drivers), the Mesa graphics library, and AMD drivers. Would you like to do that now [y/n]?'
    read install_amd_driver
    if [ $install_amd_driver = "y" ]
    then
        apt-get install firmware-linux-nonfree libgl1-mesa-dri xserver-xorg-video-amdgpu
    fi
    echo 'It is recommended that you install Vulkan as well in order to get better performance in applications that use it (such as Lutris and Wine). Would you like to do that now [y/n]?'
    read install_vulkan
    if [ $install_vulkan = "y" ]
    then
        apt-get install mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers
    fi
fi