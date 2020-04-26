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
echo 'Are you running on an [n]vidia or [a]md graphics card?'
read gpu
if [ $gpu = "n" ]
then
    gpu="Nvidia"
elif [ $gpu = "a" ]
then
    gpu="AMD"
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
    read appended_apt_sources_1
    echo 'You should update apt now, would you like to do that now [y/n]?'
    read update_apt_1
    if [ $update_apt_1 = "y" ]
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
            echo 'It is recommended that you install nvidia-vulkan-icd as well in order to get better performance in applications that use it (such as Lutris and Wine). Would you like to do that as well [y/n]?'
            read install_vulkan_nvidia
            if [ $use_backports = "y" ]
            then
                apt-get update
                apt-get install -t buster-backports nvidia-driver
                if [ $install_vulkan_nvidia = "y" ]
                then
                    apt-get install -t buster-backports nvidia-vulkan-icd
                fi
            else
                apt-get update
                apt-get install nvidia-driver
                if [ $install_vulkan_nvidia = "y" ]
                then
                    apt-get install nvidia-vulkan-icd
                fi
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
elif [ $gpu = "AMD" ]
then
    echo 'In order to proceed with the installation of the necessary packages to update your graphics drivers, you need to allow non-free packages in your apt sources by doing the following:'
    if [ $debian_version = "buster" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append the line:'
        echo 'deb http://deb.dappended_apt_sourcesebian.org/debian/ buster main contrib non-free'
    elif [ $debian_version = "bullseye/sid" ]
    then
        echo 'Open /etc/apt/sources.list with your preferred text editor, and add/append this line if you are on testing:'
        echo 'deb http://deb.debian.org/debian/ bullseye main contrib non-free'
        echo 'Or this line if you are on sid:'
        echo 'deb http://deb.debian.org/debian/ sid main contrib non-free'
    fi
    echo 'Once you have modified your sources, you are ready to install the required graphics packages. Have you appended your apt source with non-free [y/n]?'
    read appended_apt_sources_2
    echo 'You should update apt now, would you like to do that now [y/n]?'
    read update_apt_2
    if [ $update_apt_2 = "y" ]
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
    read install_vulkan_amd
    if [ $install_vulkan_amd = "y" ]
    then
        apt-get install mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers
    fi
fi
echo 'Steam is a video game digital distribution service by Valve, and is the largest digital distribution platform for PC gaming. It has official support for GNU/Linux, and has a custom version of Wine included for running Windows-only games and software. It is recommended that you install Steam, would you like to start the process of getting Steam installed now [y/n]?'
read install_steam
if [ $install_steam = "y" ]
then
    echo 'In order to install Steam, you need to enable multi-arch, which lets you install library packages from multiple architectures on the same machine. Would you like to do that now [y/n]?'
    read enable_multi_arch_1
    if [ $enable_multi_arch_1 = "y" ]
    then
        dpkg --add-architecture i386
        apt-get update
        if [ $gpu = "Nvidia" ]
        then
            echo 'Since you enabled multi-arch, it is recommended that you install the following i386 graphics packages: nvidia-driver-libs-i386 and nvidia-vulkan-icd:i386, would you like to do that now [y/n]?'
            read install_nvidia_i368_drivers
            if [ $install_nvidia_i368_drivers = "y" ]
            then
                apt-get install nvidia-driver-libs-i386 nvidia-vulkan-icd:i386
            fi    
        elif [ $gpu = "AMD" ]
        then
            echo 'Since you enabled multi-arch, it is recommended that you install the following i386 graphics packages: libgl1:i386 and mesa-vulkan-drivers:i386, would you like to do that now [y/n]?'
            read install_amd_i368_drivers
            if [ $install_amd_i368_drivers = "y" ]
            then
                apt-get install libgl1:i386 mesa-vulkan-drivers:i386
            fi  
        fi
    fi
    echo 'Would you like to install the steam package now [y/n]?'
    read install_steam_package
    if [ $install_steam_package = "y" ]
    then
        apt-get install steam
    fi
fi
echo 'Wine is a tool that allows you to run Windows applications on Linux. It is required for many applications such as Lutris. It is recommended that you install Wine, would you like to start the process of getting Wine installed now [y/n]?'
read install_wine
if [ $install_wine = "y" ]
then
    echo 'There are three main branches of Wine: Stable, Development, and Staging. Stable is, as the name implies, the most stable branch, with the least amount of features. Wine development is rapid, with new releases in the development branch every two weeks or so. Staging contains bug fixes and features which have not been integrated into the development branch yet. The idea of Wine Staging is to provide experimental features faster to end users and to give developers the possibility to discuss and improve their patches before they are integrated into the main branch.'
    echo 'Which version of Wine would you like to install, [s]table, [d]evelopment, or [st]aging?'
    read wine_version
    if [ $wine_version = "st" ]
    then
        echo 'Since Wine Staging is not in the official debian repository, installing it would mean you need to add the Wine HQ repository key and use that repository to install and update Wine. If you do not want to do this, you can choose to install stable or development. Are you okay installing Wine Staging from the Wine HQ repository [y/n]?'
        read install_wine_staging
        if [$install_wine_staging = "n" ]
        then
            echo 'Would you like to install [s]table or [d]evelopment?'
            read wine_version_2
            wine_version=$wine_version_2
        fi
    fi
    echo 'In order to install Wine, you need to enable multi-arch, which lets you install library packages from multiple architectures on the same machine. Would you like to do that now (you do not have to do this again if you have already done this step when installing Steam) [y/n]?'
    read enable_multi_arch_2
    if [ $enable_multi_arch_2 = "y" ]
    then
        dpkg --add-architecture i386
        apt-get update
    fi
    echo 'Would you like to install the necessary Wine package now [y/n]?'
    read install_wine_package
    if [ $install_wine_package = "y" ]
    then
        if [ $wine_version = "s" ]
        then
            apt-get install wine
        elif [ $wine_version = "d" ]
        then
            apt-get install wine-development
        elif [ $wine_version = "st" ]
        then
            wget -nc https://dl.winehq.org/wine-builds/winehq.key
            apt-key add winehq.key
            if [ $debian_version = "buster" ]
            then
                echo 'Add the following line to your /etc/apt/sources.list file:'
                echo 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
                echo 'Have you added this line to your /etc/apt/sources.list file [y/n]?'
                read added_winehq_repo
                apt update
                apt install --install-recommends winehq-staging
            elif [ $debian_version = "bullseye/sid" ]
            then
                echo 'Add the following line to your /etc/apt/sources.list file:'
                echo 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main'
                echo 'Have you added this line to your /etc/apt/sources.list file [y/n]?'
                read added_winehq_repo
                apt update
                apt install --install-recommends winehq-staging
            fi
        fi
    fi
fi