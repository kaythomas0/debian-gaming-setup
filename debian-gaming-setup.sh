#!/usr/bin/env bash

if [ "$1" = "-h" -o "$1" = "--help" ]; then
	echo "Usage: debian-gaming-setup"
	echo "        Starts an interactive shell script for installing recommended"
	echo "        tools to game efficiently on Debian."
	exit 0
fi

printf 'This script will help you get all the tools you need to start gaming on Debian.\n'

# Grab Debian version
debian_version=$(cat /etc/debian_version)
if [[ $debian_version == *"10"* ]]; then
    debian_version="buster"
fi
printf "It looks like your version of Debian is %s. Is that correct [y/n]? " $debian_version
read version_confirmation
if [[ $version_confirmation =~ ^([nN][oO]|[nN])$ ]]; then
    printf 'Are you running [s]table, [t]esting, or [u]nstable? '
    read version_input
    if [[ $version_input =~ ^([sS][tT][aA][bB][lL][eE]|[sS])$ ]]; then
        debian_version="buster"
    elif [[ $version_input =~ ^([tT][eE][sS][tT][iI][nN][gG]|[tT])$ ]] || [[ $version_input =~ ^([uU][nN][sS][tT][aA][bB][lL][eE]|[uU])$ ]]; then
        debian_version="bullseye/sid"
    fi
    printf "Okay, you are running %s.\n" $debian_version
fi

# Grab graphics card
printf 'Are you running on an [n]vidia or [a]md graphics card? '
read gpu
if [[ $gpu =~ ^([nN][vV][iI][dD][iI][aA]|[nN])$ ]]; then
    gpu="Nvidia"
elif [[ $gpu =~ ^([aA][mM][dD]|[aA])$ ]]; then
    gpu="AMD"
fi
printf "Okay, you are running an %s graphics card.\n" $gpu

# Install graphics drivers
printf 'To get the best gaming performance you should install the latest graphics\ndrivers.\n'

# Nvidia drivers
if [ $gpu = "Nvidia" ]; then
    if [ $debian_version = "buster" ]; then
        printf 'Since you are running Stable, it is recommended that you use buster-backports\nto install your graphics drivers in order to get the latest versions.\n'
        printf 'Would you like to use buster-backports to install your graphics drivers [y/n]? '
        read use_backports
    fi
    printf 'In order to proceed with the installation of the necessary packages to update\nyour graphics drivers, you need to allow non-free packages in your apt sources\nby doing the following:\n'
    if [[ $use_backports =~ ^([yY][eE][sS]|[yY])$ ]]; then
        use_backports="y"
        printf 'Open /etc/apt/sources.list with your preferred text editor, and add/append the\nfollowing lines:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster-backports main contrib non-free"
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "buster" ]; then
        printf 'Open /etc/apt/sources.list with your preferred text editor, and add/append the\nline:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        printf 'Open /etc/apt/sources.list with your preferred text editor, and add/append\nthis line if you are on Testing:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ bullseye main contrib non-free"
        printf 'Or this line if you are on Sid:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    printf 'Once you have modified your sources, you are ready to install the required\ngraphics packages. Press enter once you have appended your apt source with\nnon-free.'
    read appended_apt_sources_1
    printf 'You should update apt, would you like to do that now [y/n]? '
    read update_apt_1
    if [[ $update_apt_1 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'You should update your linux kernel headers before installing your graphics\ndrivers, would you like to do that now [y/n]? '
    read update_kernel_headers
    if [[ $update_kernel_headers =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ $debian_version = "buster" ]; then
            printf 'Are you using the linux kernel from buster-backports (by default, a standard\ninstallation of Debian Stable would not use the linux kernel from\nbuster-backports) [y/n]? '
            read use_kernel_backports
        else
            use_kernel_backports="n"
        fi
        if [[ $use_kernel_backports =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get install -t buster-backports linux-headers-$(uname -r | sed 's/[^-]*-[^-]*-//')
        else
            apt-get install linux-headers-$(uname -r | sed 's/[^-]*-[^-]*-//')
        fi
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'The nvidia-detect package can be used to identify the GPU and required driver\npackage. Would you like to install and run this package now [y/n]? '
    read install_nvidia_detect
    if [[ $install_nvidia_detect =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get install nvidia-detect
        nvidia-detect
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        printf 'Did nvidia-detect recommend you install the [1]nvidia-driver,\n[2]nvidia-legacy-390xx-driver, or [3]nvidia-legacy-340xx-driver package? '
        read driver_package
    else
        printf 'You can install the [1]nvidia-driver, [2]nvidia-legacy-390xx-driver,\nor [3]nvidia-legacy-340xx-driver package.\n'
        printf '[1]nvidia-driver is for support of GeForce 600 series and newer GPUs.\n'
        printf '[2]nvidia-legacy-390xx-driver is for support of GeForce 400 and 500 series.\n'
        printf '[3]nvidia-legacy-340xx-driver is for support of GeForce 8 through 300 series\nGPUs.\n'
        printf 'Which package would you like to install? '
        read driver_package
    fi
    printf 'You should install your selected driver package to update your graphics drivers,\nwould you like to do that now [y/n]? '
    read install_nvidia_driver
    if [[ $install_nvidia_driver =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ $driver_package = "1" ]; then
            printf 'It is recommended that you install nvidia-vulkan-icd as well in order to get\nbetter performance in applications that use Vulkan (such as Lutris and Wine).\nWould you like to do that as well [y/n]? '
            read install_vulkan_nvidia
            if [ $use_backports = "y" ]; then
                apt-get update
                apt-get install -t buster-backports nvidia-driver
                if [[ $install_vulkan_nvidia =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install -t buster-backports nvidia-vulkan-icd
                fi
            else
                apt-get update
                apt-get install nvidia-driver
                if [[ $install_vulkan_nvidia =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install nvidia-vulkan-icd
                fi
            fi
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ $driver_package = "2" ]; then
            apt-get update
            apt-get install nvidia-legacy-390xx-driver
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ $driver_package = "3" ]; then
            apt-get update
            apt-get install nvidia-legacy-340xx-driver
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            printf 'You need to create an xorg configuration file. This can be done automatically\nright now, would you like to do that [y/n]? '
            read create_xorg_conf
            if [[ $create_xorg_conf =~ ^([yY][eE][sS]|[yY])$ ]]; then
                mkdir -p /etc/X11/xorg.conf.d
                echo -e 'Section "Device"\n\tIdentifier "My GPU"\n\tDriver "nvidia"\nEndSection' >/etc/X11/xorg.conf.d/20-nvidia.conf
                printf 'Xorg configuration file created.'
            fi
        fi
        printf 'If these installations ran successfully, then you have installed all the\nnecessary Nvidia graphics drivers.\n'
    else
        printf 'Nvidia graphics drivers installation aborted.\n'
    fi

# AMD drivers
elif [ $gpu = "AMD" ]; then
    printf 'In order to proceed with the installation of the necessary packages to update\nyour graphics drivers, you need to allow non-free packages in your apt sources\nby doing the following:\n'
    if [ $debian_version = "buster" ]; then
        printf 'Open /etc/apt/sources.list with your preferred text editor, and add/append the\nline:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        printf 'Open /etc/apt/sources.list with your preferred text editor, and add/append\nthis line if you are on Testing:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ bullseye main contrib non-free"
        printf 'Or this line if you are on Sid:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    printf 'Once you have modified your sources, you are ready to install the required\ngraphics packages. Press enter once you have appended your apt source with\nnon-free.'
    read appended_apt_sources_2
    printf 'You should update apt, would you like to do that now [y/n]? '
    read update_apt_2
    if [[ $update_apt_2 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'You are ready to install the non-free Linux firmware (required for the AMD\ndrivers), the Mesa graphics library, and AMD drivers. Would you like to do that\nnow [y/n]? '
    read install_amd_driver
    if [[ $install_amd_driver =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get install firmware-linux-nonfree libgl1-mesa-dri xserver-xorg-video-amdgpu
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        printf 'It is recommended that you install Vulkan as well in order to get better\nperformance in applications that use it (such as Lutris and Wine). Would you\nlike to do that now [y/n]? '
        read install_vulkan_amd
        if [[ $install_vulkan_amd =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get install mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        fi
        printf 'If these installations ran successfully, then you have installed all the\nnecessary AMD graphics drivers.\n'
    else
        printf 'AMD graphics drivers installation aborted.\n'
    fi
fi

# Steam installation
printf 'Steam is a video game digital distribution service by Valve, and is the largest\ndigital distribution platform for PC gaming. It has official support for\nGNU/Linux, and has a custom version of Wine included for running Windows-only\ngames and software. It is recommended that you install Steam, would you like to\nstart the process of getting Steam installed now [y/n]? '
read install_steam
if [[ $install_steam =~ ^([yY][eE][sS]|[yY])$ ]]; then
    printf 'In order to install Steam, you need to enable multi-arch, which lets you\ninstall library packages from multiple architectures on the same machine. Would\nyou like to do that now [y/n]? '
    read enable_multi_arch_1
    if [[ $enable_multi_arch_1 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        dpkg --add-architecture i386
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        if [ $gpu = "Nvidia" ]; then
            printf 'Since you enabled multi-arch, it is recommended that you install the following\ni386 graphics packages: nvidia-driver-libs-i386 and nvidia-vulkan-icd:i386,\nwould you like to do that now [y/n]? '
            read install_nvidia_i368_drivers
            if [[ $install_nvidia_i368_drivers =~ ^([yY][eE][sS]|[yY])$ ]]; then
                apt-get install nvidia-driver-libs-i386 nvidia-vulkan-icd:i386
            fi
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ $gpu = "AMD" ]; then
            printf 'Since you enabled multi-arch, it is recommended that you install the following\ni386 graphics packages: libgl1:i386 and mesa-vulkan-drivers:i386, would you\nlike to do that now [y/n]? '
            read install_amd_i368_drivers
            if [[ $install_amd_i368_drivers =~ ^([yY][eE][sS]|[yY])$ ]]; then
                apt-get install libgl1:i386 mesa-vulkan-drivers:i386
            fi
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        fi
    fi
    printf 'Would you like to install the steam package now [y/n]? '
    read install_steam_package
    if [[ $install_steam_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get install steam
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        printf 'If these installations ran successfully, then you have setup Steam.\n'
    else
        printf 'Steam installation aborted.\n'
    fi
fi

# Wine installation
printf 'Wine is a tool that allows you to run Windows applications on Linux. It is\nrequired for many applications such as Lutris. It is recommended that you\ninstall Wine, would you like to start the process of getting Wine installed now\n[y/n]? '
read install_wine
if [[ $install_wine =~ ^([yY][eE][sS]|[yY])$ ]]; then
    printf 'There are three main branches of Wine: Stable, Development, and Staging. Stable\nis, as the name implies, the most stable branch, with the least amount of\nfeatures. Wine development is rapid, with new releases in the development\nbranch every two weeks or so. Staging contains bug fixes and features which\nhave not been integrated into the development branch yet. The idea of Wine\nStaging is to provide experimental features faster to end users and to give\ndevelopers the possibility to discuss and improve their patches before they are\nintegrated into the main branch.\n'
    printf 'Which version of Wine would you like to install: [s]table, [d]evelopment, or\n[st]aging? '
    read wine_version
    if [[ $wine_version =~ ^([sS][tT][aA][gG][iI][nN][gG]|[sS][tT])$ ]]; then
        wine_version="st"
        printf 'Since Wine Staging is not in the official Debian repository, installing it\nwould mean you need to add the Wine HQ repository key and use that repository\nto install and update Wine. If you do not want to do this, you can choose to\ninstall the stable or development branch of Wine. Are you okay installing Wine\nStaging from the Wine HQ repository [y/n]? '
        read install_wine_staging
        if [[ $install_wine_staging =~ ^([nN][oO]|[nN])$ ]]; then
            printf 'Would you like to install [s]table or [d]evelopment? '
            read wine_version_2
            if [[ $wine_version_2 =~ ^([sS][tT][aA][bB][lL][eE]|[sS])$ ]]; then
                wine_version="s"
            elif [[ $wine_version_2 =~ ^([dD][eE][vV][eE][lL][oO][pP][mM][eE][nN][tT]|[dD])$ ]]; then
                wine_version="d"
            fi
        fi
    elif [[ $wine_version =~ ^([sS][tT][aA][bB][lL][eE]|[sS])$ ]]; then
        wine_version="s"
    elif [[ $wine_version =~ ^([dD][eE][vV][eE][lL][oO][pP][mM][eE][nN][tT]|[dD])$ ]]; then
        wine_version="d"
    fi
    printf 'In order to install Wine, you need to enable multi-arch, which lets you install\nlibrary packages from multiple architectures on the same machine. Would you\nlike to do that now (you do not have to do this again if you have already done\nthis step when installing Steam) [y/n]? '
    read enable_multi_arch_2
    if [[ $enable_multi_arch_2 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        dpkg --add-architecture i386
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'Would you like to install the necessary Wine package now [y/n]? '
    read install_wine_package
    if [[ $install_wine_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ $wine_version = "s" ]; then
            apt-get install wine
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ $wine_version = "d" ]; then
            apt-get install wine-development
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ $wine_version = "st" ]; then
            wget -nc https://dl.winehq.org/wine-builds/winehq.key
            apt-key add winehq.key
            if [ $debian_version = "buster" ]; then
                printf 'Add the following line to your /etc/apt/sources.list file:\n'
                printf "\e[32m%s\e[0m\n" "deb https://dl.winehq.org/wine-builds/debian/ buster main"
                printf 'Press enter once you have added this line. '
                read added_winehq_repo
                apt update
                apt install --install-recommends winehq-staging
            elif [ $debian_version = "bullseye/sid" ]; then
                printf 'Add the following line to your /etc/apt/sources.list file:\n'
                printf "\e[32m%s\e[0m\n" "deb https://dl.winehq.org/wine-builds/debian/ bullseye main"
                printf 'Press enter once you have added this line. '
                read added_winehq_repo
                apt update
                apt install --install-recommends winehq-staging
            fi
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        fi
        printf 'If these installations ran successfully, then you have setup Wine.\n'
    else
        printf 'Wine installation aborted.\n'
    fi
fi

# Lutris installation
printf 'Lutris is a FOSS game manager for Linux-based operating systems. It uses Wine\nand other tools like DXVK to make managing and running games much easier on\nLinux. It is recommended that you install Lutris, would you like to start the\nprocess of getting Lutris installed now [y/n]? '
read install_lutris
if [[ $install_lutris =~ ^([yY][eE][sS]|[yY])$ ]]; then
    printf 'Lutris requires you have Wine installed on your system. If you do not have\nWine, you will not be able to continue with this installation process. Do you\nhave Wine installed on your system [y/n]? '
    read installed_wine
    if [[ $installed_wine =~ ^([yY][eE][sS]|[yY])$ ]]; then
        printf 'Lutris is not in the official Debian repository. According to the Lutris\nwebsite, the way to install Lutris from an auto-updating repository is using\nthe openSUSE Build Service Repository, which requires adding a key for this\nrepository. If this is not something you want to do, you can also download the\n.deb file from the openSUSE website and install Lutris using that, or download\nthe tar.xz package from Lutris and run the project directly from the extracted\narchive.\n'
        printf 'Would you like to [1]use the openSUSE Build Service Repository, [2]download and\ninstall the .deb file from the openSUSE website, or [3]download the tar.xz\npackage from Lutris and run the project directly from the extracted archive? '
        read lutris_installation_choice
        if [ $lutris_installation_choice = "1" ]; then
            if [ $debian_version = "buster" ]; then
                printf 'Would you like to add the\nhttp://download.opensuse.org/repositories/home:/strycore/Debian_10/ repository\nand key to your apt sources, and install Lutris now [y/n]? '
                read install_lutris_package
                if [[ $install_lutris_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ /' >/etc/apt/sources.list.d/home:strycore.list
                    wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_10/Release.key -O Release.key
                    apt-key add - <Release.key
                    apt-get update
                    apt-get install lutris
                    printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                    printf 'If these installations ran successfully, then you have setup Lutris.\n'
                else
                    printf 'Lutris installation aborted.\n'
                fi
            elif [ $debian_version = "bullseye/sid "]; then
                printf 'Are you running Debian [t]esting or [u]nstable? '
                read testing_or_unstable
                if [[ $testing_or_unstable =~ ^([tT][eE][sS][tT][iI][nN][gG]|[tT])$ ]]; then
                    printf 'Would you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/\n repository and key to your apt sources, and install Lutris now [y/n]? '
                    read install_lutris_package
                    if [[ $install_lutris_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
                        echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/ /' >/etc/apt/sources.list.d/home:strycore.list
                        wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_Testing/Release.key -O Release.key
                        apt-key add - <Release.key
                        apt-get update
                        apt-get install lutris
                        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                        printf 'If these installations ran successfully, then you have setup Lutris.\n'
                    else
                        printf 'Lutris installation aborted.\n'
                    fi
                elif [[ $testing_or_unstable =~ ^([uU][nN][sS][tT][aA][bB][lL][eE]|[uU])$ ]]; then
                    printf 'Would you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/\n repository and key to your apt sources, and install Lutris now [y/n]? '
                    read install_lutris_package
                    if [[ $install_lutris_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
                        echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/ /' >/etc/apt/sources.list.d/home:strycore.list
                        wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_Unstable/Release.key -O Release.key
                        apt-key add - <Release.key
                        apt-get update
                        apt-get install lutris
                        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                        printf 'If these installations ran successfully, then you have setup Lutris.\n'
                    else
                        printf 'Lutris installation aborted.\n'
                    fi
                fi
            fi
        elif [ $lutris_installation_choice = "2" ]; then
            printf 'You can download the Lutris .deb file for your version of Debian directly from\nthe openSUSE build service site here:\nhttps://software.opensuse.org/download.html?project=home%3Astrycore&package=lutris\n'
            printf 'Go to the link, click "Grab binary packages directly", and download the Lutris\n.deb file for your version of Debian.\n'
            printf 'Navigate to the directory where you downloaded the .deb file, and install it by\nrunning the following command (replacing the version number with the version\nyou downloaded):\n'
            printf "\e[32m%s\e[0m\n" "sudo apt install ./lutris_0.5.6_amd64"
        elif [ $lutris_installation_choice = "3" ]; then
            printf 'You can download the tar.xz package from Lutris and run the project directly\nfrom the extracted archive. To do that, go to the Lutris download page here:\nhttps://lutris.net/downloads/, navigate to the "Tarball" section, and follow\nthe instructions there.\n'
        fi
    fi
fi
printf 'If all these installs ran successfully, then you have setup all the recommended\nthings to get started gaming on Debian.\n'
