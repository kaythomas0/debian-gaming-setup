#!/usr/bin/env bash

confirm_debian_version() {
    printf "\nIt looks like your version of Debian is %s. Is that correct [y/n]? " "$debian_version"
    local version_confirmation
    read -r version_confirmation
    if [[ $version_confirmation =~ ^([nN][oO]|[nN])$ ]]; then
        printf '\nAre you running [s]table, [t]esting, or [u]nstable? '
        local version_input
        read -r version_input
        if [[ $version_input =~ ^([sS][tT][aA][bB][lL][eE]|[sS])$ ]]; then
            debian_version="buster"
        elif [[ $version_input =~ ^([tT][eE][sS][tT][iI][nN][gG]|[tT])$ ]] || [[ $version_input =~ ^([uU][nN][sS][tT][aA][bB][lL][eE]|[uU])$ ]]; then
            debian_version="bullseye/sid"
        fi
        printf "\nOkay, you are running %s.\n" $debian_version
    fi
}

confirm_debian_version_gui() {
    if ! zenity --width="$gui_width" --height="$gui_height" --question --text="It looks like your version of Debian is $debian_version. Is that correct?"; then
        local version_input
        version_input="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Which version of Debian are you running?" --column="Debian Release" "Stable (Buster)" "Testing (Bullseye)" "Unstable (Sid)")"
        if [ "$version_input" = "Stable (Buster)" ]; then
            debian_version="buster"
        elif [ "$version_input" = "Testing (Bullseye)" ] || [ "$version_input" = "Unstable (Sid)" ]; then
            debian_version="bullseye/sid"
        fi
        zenity --width="$gui_width" --height="$gui_height" --info --text="Okay, you are running $debian_version."
    fi
}

gpu_prompt() {
    printf '\nAre you running on an [n]vidia or [a]md graphics card? '
    local gpu_check
    read -r gpu_check
    if [[ $gpu_check =~ ^([nN][vV][iI][dD][iI][aA]|[nN])$ ]]; then
        gpu="Nvidia"
    elif [[ $gpu_check =~ ^([aA][mM][dD]|[aA])$ ]]; then
        gpu="AMD"
    fi
}

grab_graphics_card() {
    # Check if the lspci package isn't installed
    if ! (lspci --version) >/dev/null 2>&1; then
        gpu_prompt
    elif [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [nN][vV][iI][dD][iI][aA] ]]; then
        printf '\nNvidia graphics card detected. Are you running an nvidia graphics card [y/n]? '
        local nvidia_check_1
        read -r nvidia_check_1
        if [[ $nvidia_check_1 =~ ^([nN][oO]|[nN])$ ]]; then
            printf '\nAre you running an AMD graphics card [y/n]? '
            local amd_check_1
            read -r amd_check_1
            if [[ $amd_check_1 =~ ^([nN][oO]|[nN])$ ]]; then
                printf '\nSorry, this script only supports Nvidia and AMD graphics cards.\n'
                exit 0
            else
                gpu="AMD"
            fi
        else
            gpu="Nvidia"
        fi
    elif [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [aA][mM][dD] ]]; then
        printf '\nAMD graphics card detected. Are you running an AMD graphics card [y/n]? '
        local amd_check_2
        read -r amd_check_2
        if [[ $amd_check_2 =~ ^([nN][oO]|[nN])$ ]]; then
            printf '\nAre you running an Nvidia graphics card [y/n]? '
            local nvidia_check_2
            read -r nvidia_check_2
            if [[ $nvidia_check_2 =~ ^([nN][oO]|[nN])$ ]]; then
                printf '\nSorry, this script only supports Nvidia and AMD graphics cards.\n'
                exit 0
            else
                gpu="Nvidia"
            fi
        else
            gpu="AMD"
        fi
    else
        gpu_prompt
    fi
    printf "\nOkay, you are running an %s graphics card.\n" $gpu
}

gpu_prompt_gui() {
    local gpu_check
    gpu_check="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Are you running on an Nvidia or AMD graphics card?" --column="Debian Release" "Nvidia" "AMD")"
    if [[ "$gpu_check" = "Nvidia" ]]; then
        gpu="Nvidia"
    elif [[ "$gpu_check" = "AMD" ]]; then
        gpu="AMD"
    fi
}

grab_graphics_card_gui() {
    # Check if the lspci package isn't installed
    if ! (lspci --version) >/dev/null 2>&1; then
        gpu_prompt_gui
    elif [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [nN][vV][iI][dD][iI][aA] ]]; then
        if zenity --width="$gui_width" --height="$gui_height" --question --text="Nvidia graphics card detected. Are you running an nvidia graphics card?"; then
            gpu="Nvidia"
        else
            if zenity --width="$gui_width" --height="$gui_height" --question --text="Are you running an AMD graphics card?"; then
                gpu="AMD"
            else
                zenity --width="$gui_width" --height="$gui_height" --info --text="Sorry, this script only supports Nvidia and AMD graphics cards."
                exit 0
            fi
        fi
    elif [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [aA][mM][dD] ]]; then
        if zenity --width="$gui_width" --height="$gui_height" --question --text="AMD graphics card detected. Are you running an AMD graphics card?"; then
            gpu="AMD"
        else
            if zenity --width="$gui_width" --height="$gui_height" --question --text="Are you running an Nvidia graphics card?"; then
                gpu="Nvidia"
            else
                zenity --width="$gui_width" --height="$gui_height" --info --text="Sorry, this script only supports Nvidia and AMD graphics cards."
                exit 0
            fi
        fi
    else
        gpu_prompt_gui
    fi
    zenity --width="$gui_width" --height="$gui_height" --info --text="Okay, you are running an $gpu graphics card."
}

install_nvidia_tools() {
    if [ $debian_version = "buster" ]; then
        printf '\nSince you are running Stable, it is recommended that you use buster-backports\nto install your graphics drivers in order to get the latest versions.\n'
        printf '\nWould you like to use buster-backports to install your graphics drivers [y/n]? '
        local use_backports
        read -r use_backports
    fi
    printf '\nIn order to proceed with the installation of the necessary packages to update\nyour graphics drivers, you need to allow non-free packages in your apt sources\nby doing the following:\n'
    if [[ $use_backports =~ ^([yY][eE][sS]|[yY])$ ]]; then
        use_backports="y"
        printf '\nOpen /etc/apt/sources.list with your preferred text editor, and add/append the\nfollowing lines:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster-backports main contrib non-free"
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "buster" ]; then
        printf '\nOpen /etc/apt/sources.list with your preferred text editor, and add/append the\nline:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        printf '\nOpen /etc/apt/sources.list with your preferred text editor, and add/append\nthis line if you are on Testing:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ bullseye main contrib non-free"
        printf 'Or this line if you are on Sid:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    printf '\nOnce you have modified your sources, you are ready to install the required\ngraphics packages. Press enter once you have appended your apt source with\nnon-free.'
    local appended_apt_sources_1
    # shellcheck disable=SC2034  # Unused variable left for readability
    read -r appended_apt_sources_1
    printf '\nYou should update apt, would you like to do that now [y/n]? '
    local update_apt_1
    read -r update_apt_1
    if [[ $update_apt_1 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'You should update your linux kernel headers before installing your graphics\ndrivers, would you like to do that now [y/n]? '
    local update_kernel_headers
    read -r update_kernel_headers
    if [[ $update_kernel_headers =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ $debian_version = "buster" ]; then
            printf '\nAre you using the linux kernel from buster-backports (by default, a standard\ninstallation of Debian Stable would not use the linux kernel from\nbuster-backports) [y/n]? '
            local use_kernel_backports
            read -r use_kernel_backports
        else
            use_kernel_backports="n"
        fi
        if [[ $use_kernel_backports =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get install -t buster-backports linux-headers-"$(uname -r | sed 's/[^-]*-[^-]*-//')"
        else
            apt-get install linux-headers-"$(uname -r | sed 's/[^-]*-[^-]*-//')"
        fi
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'The nvidia-detect package can be used to identify the GPU and required driver\npackage. Would you like to install and run this package now [y/n]? '
    local install_nvidia_detect
    read -r install_nvidia_detect
    if [[ $install_nvidia_detect =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get install nvidia-detect
        nvidia-detect
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        printf 'Did nvidia-detect recommend you install the [1]nvidia-driver,\n[2]nvidia-legacy-390xx-driver, or [3]nvidia-legacy-340xx-driver package? '
        local driver_package
        read -r driver_package
    else
        printf '\nYou can install the [1]nvidia-driver, [2]nvidia-legacy-390xx-driver,\nor [3]nvidia-legacy-340xx-driver package.\n'
        printf '[1]nvidia-driver is for support of GeForce 600 series and newer GPUs.\n'
        printf '[2]nvidia-legacy-390xx-driver is for support of GeForce 400 and 500 series.\n'
        printf '[3]nvidia-legacy-340xx-driver is for support of GeForce 8 through 300 series\nGPUs.\n'
        printf 'Which package would you like to install? '
        local driver_package
        read -r driver_package
    fi
    printf '\nYou should install your selected driver package to update your graphics drivers,\nwould you like to do that now [y/n]? '
    local install_nvidia_driver
    read -r install_nvidia_driver
    if [[ $install_nvidia_driver =~ ^([yY][eE][sS]|[yY])$ ]]; then
        if [ "$driver_package" = "1" ]; then
            printf '\nIt is recommended that you install nvidia-vulkan-icd as well in order to get\nbetter performance in applications that use Vulkan (such as Lutris and Wine).\nWould you like to do that as well [y/n]? '
            local install_vulkan_nvidia
            read -r install_vulkan_nvidia
            if [ $use_backports = "y" ]; then
                apt-get update
                apt-get install -t buster-backports nvidia-driver
                if [[ $install_vulkan_nvidia =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install -t buster-backports nvidia-vulkan-icd
                fi
                printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            else
                apt-get update
                apt-get install nvidia-driver
                if [[ $install_vulkan_nvidia =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install nvidia-vulkan-icd
                fi
                printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            fi
        elif [ "$driver_package" = "2" ]; then
            apt-get update
            apt-get install nvidia-legacy-390xx-driver
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        elif [ "$driver_package" = "3" ]; then
            apt-get update
            apt-get install nvidia-legacy-340xx-driver
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            printf 'You need to create an xorg configuration file. This can be done automatically\nright now, would you like to do that [y/n]? '
            local create_xorg_conf
            read -r create_xorg_conf
            if [[ $create_xorg_conf =~ ^([yY][eE][sS]|[yY])$ ]]; then
                mkdir -p /etc/X11/xorg.conf.d
                echo -e 'Section "Device"\n\tIdentifier "My GPU"\n\tDriver "nvidia"\nEndSection' >/etc/X11/xorg.conf.d/20-nvidia.conf
                printf 'Xorg configuration file created.'
            fi
        fi
        printf '\nIf these installations ran successfully, then you have installed all the\nnecessary Nvidia graphics drivers.\n'
    else
        printf '\nNvidia graphics drivers installation aborted.\n'
    fi
}

install_nvidia_tools_gui() {
    if [ $debian_version = "buster" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Since you are running Stable, it is recommended that you use buster-backports to install your graphics drivers in order to get the latest versions."
        local use_backports
        if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to use buster-backports to install your graphics drivers?"; then
            use_backports="y"
        fi
    fi
    zenity --width="$gui_width" --height="$gui_height" --info --text="In order to proceed with the installation of the necessary packages to update your graphics drivers, you need to allow non-free packages in your apt sources by doing the following:"
    if [ "$use_backports" = "y" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append the following lines:\ndeb http://deb.debian.org/debian buster-backports main contrib non-free\ndeb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "buster" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append the line:\ndeb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append this line if you are on Testing:\ndeb http://deb.debian.org/debian/ bullseye main contrib non-free\nOr this line if you are on Sid:\ndeb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    zenity --width="$gui_width" --height="$gui_height" --info --text="Once you have modified your sources, you are ready to install the required graphics packages. Press OK once you have appended your apt source with non-free."
    if zenity --width="$gui_width" --height="$gui_height" --question --text="You should update apt, would you like to do that now?"; then
        apt-get update
    fi
    if zenity --width="$gui_width" --height="$gui_height" --question --text="You should update your linux kernel headers before installing your graphics drivers, would you like to do that now?"; then
        if [ $debian_version = "buster" ]; then
            if zenity --width="$gui_width" --height="$gui_height" --question --text="Are you using the linux kernel from buster-backports (by default, a standard installation of Debian Stable would not use the linux kernel from buster-backports)?"; then
                local use_kernel_backports
                use_kernel_backports="y"
            fi
        else
            use_kernel_backports="n"
        fi
        if [ "$use_kernel_backports" = "y" ]; then
            apt-get install -t buster-backports linux-headers-"$(uname -r | sed 's/[^-]*-[^-]*-//')"
        else
            apt-get install linux-headers-"$(uname -r | sed 's/[^-]*-[^-]*-//')"
        fi
    fi
    if zenity --width="$gui_width" --height="$gui_height" --question --text="The nvidia-detect package can be used to identify the GPU and required driver package. Would you like to install and run this package now?"; then
        apt-get install nvidia-detect
        nvidia-detect
        local driver_package
        driver_package="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Which package did nvidia-detect recommend you install?" --column="Package" "nvidia-driver" "nvidia-legacy-390xx-driver" "nvidia-legacy-340xx-driver")"
    else
        local driver_package
        driver_package="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Which driver package would you like to install?" --column="Package" --column="Info" "nvidia-driver" "GeForce 600 series and newer" "nvidia-legacy-390xx-driver" "GeForce 400 and 500 series" "nvidia-legacy-340xx-driver" "GeForce 8 through 300 series")"
    fi
    if zenity --width="$gui_width" --height="$gui_height" --question --text="You should install your selected driver package to update your graphics drivers, would you like to do that now?"; then
        if [ "$driver_package" = "nvidia-driver" ]; then
            if zenity --width="$gui_width" --height="$gui_height" --question --text="It is recommended that you install nvidia-vulkan-icd as well in order to get better performance in applications that use Vulkan (such as Lutris and Wine). Would you like to do that as well?"; then
                if [ $use_backports = "y" ]; then
                    apt-get update
                    apt-get install -t buster-backports nvidia-driver
                    apt-get install -t buster-backports nvidia-vulkan-icd
                else
                    apt-get update
                    apt-get install nvidia-driver
                    apt-get install nvidia-vulkan-icd
                fi
            else
                if [ $use_backports = "y" ]; then
                    apt-get update
                    apt-get install -t buster-backports nvidia-driver
                else
                    apt-get update
                    apt-get install nvidia-driver
                fi
            fi
        elif [ "$driver_package" = "nvidia-legacy-390xx-driver" ]; then
            apt-get update
            apt-get install nvidia-legacy-390xx-driver
        elif [ "$driver_package" = "nvidia-legacy-340xx-driver" ]; then
            apt-get update
            apt-get install nvidia-legacy-340xx-driver
            if zenity --width="$gui_width" --height="$gui_height" --question --text="You need to create an xorg configuration file. This can be done automatically\nright now, would you like to do that?"; then
                mkdir -p /etc/X11/xorg.conf.d
                echo -e 'Section "Device"\n\tIdentifier "My GPU"\n\tDriver "nvidia"\nEndSection' >/etc/X11/xorg.conf.d/20-nvidia.conf
                zenity --width="$gui_width" --height="$gui_height" --info --text="Xorg configuration file created."
            fi
        fi
        zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have installed all the necessary Nvidia graphics drivers."
    else
        zenity --width="$gui_width" --height="$gui_height" --info --text="Nvidia graphics drivers installation aborted."
    fi
}

install_amd_tools() {
    printf '\nIn order to proceed with the installation of the necessary packages to update\nyour graphics drivers, you need to allow non-free packages in your apt sources\nby doing the following:\n'
    if [ $debian_version = "buster" ]; then
        printf '\nOpen /etc/apt/sources.list with your preferred text editor, and add/append the\nline:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        printf '\nOpen /etc/apt/sources.list with your preferred text editor, and add/append\nthis line if you are on Testing:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ bullseye main contrib non-free"
        printf 'Or this line if you are on Sid:\n'
        printf "\e[32m%s\e[0m\n" "deb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    printf '\nOnce you have modified your sources, you are ready to install the required\ngraphics packages. Press enter once you have appended your apt source with\nnon-free.'
    local appended_apt_sources_2
    # shellcheck disable=SC2034  # Unused variable left for readability
    read -r appended_apt_sources_2
    printf '\nYou should update apt, would you like to do that now [y/n]? '
    local update_apt_2
    read -r update_apt_2
    if [[ $update_apt_2 =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get update
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
    fi
    printf 'You are ready to install the non-free Linux firmware (required for the AMD\ndrivers), the Mesa graphics library, and AMD drivers. Would you like to do that\nnow [y/n]? '
    local install_amd_driver
    read -r install_amd_driver
    if [[ $install_amd_driver =~ ^([yY][eE][sS]|[yY])$ ]]; then
        apt-get install firmware-linux-nonfree libgl1-mesa-dri xserver-xorg-video-amdgpu
        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        printf 'It is recommended that you install Vulkan as well in order to get better\nperformance in applications that use it (such as Lutris and Wine). Would you\nlike to do that now [y/n]? '
        local install_vulkan_amd
        read -r install_vulkan_amd
        if [[ $install_vulkan_amd =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get install mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        fi
        printf 'If these installations ran successfully, then you have installed all the\nnecessary AMD graphics drivers.\n'
    else
        printf '\nAMD graphics drivers installation aborted.\n'
    fi
}

install_amd_tools_gui() {
    zenity --width="$gui_width" --height="$gui_height" --info --text="In order to proceed with the installation of the necessary packages to update your graphics drivers, you need to allow non-free packages in your apt sources by doing the following:"
    if [ "$use_backports" = "y" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append the following lines:\ndeb http://deb.debian.org/debian buster-backports main contrib non-free\ndeb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "buster" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append the line:\ndeb http://deb.debian.org/debian buster main contrib non-free"
    elif [ $debian_version = "bullseye/sid" ]; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="Open /etc/apt/sources.list with your preferred text editor, and add/append this line if you are on Testing:\ndeb http://deb.debian.org/debian/ bullseye main contrib non-free\nOr this line if you are on Sid:\ndeb http://deb.debian.org/debian/ sid main contrib non-free"
    fi
    zenity --width="$gui_width" --height="$gui_height" --info --text="Once you have modified your sources, you are ready to install the required graphics packages. Press OK once you have appended your apt source with non-free."
    if zenity --width="$gui_width" --height="$gui_height" --question --text="You should update apt, would you like to do that now?"; then
        apt-get update
    fi
    if zenity --width="$gui_width" --height="$gui_height" --question --text="You are ready to install the non-free Linux firmware (required for the AMD\ rivers), the Mesa graphics library, and AMD drivers. Would you like to do that now?"; then
        apt-get install firmware-linux-nonfree libgl1-mesa-dri xserver-xorg-video-amdgpu
        if zenity --width="$gui_width" --height="$gui_height" --question --text="It is recommended that you install Vulkan as well in order to get better performance in applications that use it (such as Lutris and Wine). Would you like to do that now?"; then
            apt-get install mesa-vulkan-drivers libvulkan1 vulkan-tools vulkan-utils vulkan-validationlayers
        fi
        zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have installed all the necessary AMD graphics drivers."
    else
        zenity --width="$gui_width" --height="$gui_height" --info --text="AMD graphics drivers installation aborted."
    fi
}

setup_steam() {
    printf '\nSteam is a video game digital distribution service by Valve, and is the largest\ndigital distribution platform for PC gaming. It has official support for\nGNU/Linux, and has a custom version of Wine included for running Windows-only\ngames and software. It is recommended that you install Steam, would you like to\nstart the process of getting Steam installed now [y/n]? '
    local install_steam
    read -r install_steam
    if [[ $install_steam =~ ^([yY][eE][sS]|[yY])$ ]]; then
        printf '\nIn order to install Steam, you need to enable multi-arch, which lets you\ninstall library packages from multiple architectures on the same machine. Would\nyou like to do that now [y/n]? '
        local enable_multi_arch_1
        read -r enable_multi_arch_1
        if [[ $enable_multi_arch_1 =~ ^([yY][eE][sS]|[yY])$ ]]; then
            dpkg --add-architecture i386
            apt-get update
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            if [ $gpu = "Nvidia" ]; then
                printf 'Since you enabled multi-arch, it is recommended that you install the following\ni386 graphics packages: nvidia-driver-libs-i386 and nvidia-vulkan-icd:i386,\nwould you like to do that now [y/n]? '
                local install_nvidia_i368_drivers
                read -r install_nvidia_i368_drivers
                if [[ $install_nvidia_i368_drivers =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install nvidia-driver-libs-i386 nvidia-vulkan-icd:i386
                    printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                fi
            elif [ $gpu = "AMD" ]; then
                printf 'Since you enabled multi-arch, it is recommended that you install the following\ni386 graphics packages: libgl1:i386 and mesa-vulkan-drivers:i386, would you\nlike to do that now [y/n]? '
                local install_amd_i368_drivers
                read -r install_amd_i368_drivers
                if [[ $install_amd_i368_drivers =~ ^([yY][eE][sS]|[yY])$ ]]; then
                    apt-get install libgl1:i386 mesa-vulkan-drivers:i386
                    printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                fi
            fi
        fi
        printf 'Would you like to install the steam package now [y/n]? '
        local install_steam_package
        read -r install_steam_package
        if [[ $install_steam_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
            apt-get install steam
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            printf 'If these installations ran successfully, then you have setup Steam.\n'
        else
            printf '\nSteam installation aborted.\n'
        fi
    fi
}

setup_steam_gui() {
    if zenity --width="$gui_width" --height="$gui_height" --question --text="Steam is a video game digital distribution service by Valve, and is the largest digital distribution platform for PC gaming. It has official support for GNU/Linux, and has a custom version of Wine included for running Windows-only games and software. It is recommended that you install Steam, would you like to start the process of getting Steam installed now?"; then
        if zenity --width="$gui_width" --height="$gui_height" --question --text="In order to install Steam, you need to enable multi-arch, which lets you install library packages from multiple architectures on the same machine. Would you like to do that now?"; then
            dpkg --add-architecture i386
            apt-get update
            if [ "$gpu" = "Nvidia" ]; then
                if zenity --width="$gui_width" --height="$gui_height" --question --text="Since you enabled multi-arch, it is recommended that you install the following i386 graphics packages: nvidia-driver-libs-i386 and nvidia-vulkan-icd:i386, would you like to do that now?"; then
                    apt-get install nvidia-driver-libs-i386 nvidia-vulkan-icd:i386
                fi
            elif [ "$gpu" = "AMD" ]; then
                if zenity --width="$gui_width" --height="$gui_height" --question --text="Since you enabled multi-arch, it is recommended that you install the following i386 graphics packages: libgl1:i386 and mesa-vulkan-drivers:i386, would you like to do that now?"; then
                    apt-get install libgl1:i386 mesa-vulkan-drivers:i386
                fi
            fi
        fi
        if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to install the steam package now?"; then
            apt-get install steam
            zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have setup Steam."
        else
            zenity --width="$gui_width" --height="$gui_height" --info --text="Steam installation aborted."
        fi
    fi
}

setup_wine() {
    printf '\nWine is a tool that allows you to run Windows applications on Linux. It is\nrequired for many applications such as Lutris. It is recommended that you\ninstall Wine, would you like to start the process of getting Wine installed now\n[y/n]? '
    local install_wine
    read -r install_wine
    if [[ $install_wine =~ ^([yY][eE][sS]|[yY])$ ]]; then
        printf '\nThere are three main branches of Wine: Stable, Development, and Staging. Stable\nis, as the name implies, the most stable branch, with the least amount of\nfeatures. Wine development is rapid, with new releases in the development\nbranch every two weeks or so. Staging contains bug fixes and features which\nhave not been integrated into the development branch yet. The idea of Wine\nStaging is to provide experimental features faster to end users and to give\ndevelopers the possibility to discuss and improve their patches before they are\nintegrated into the main branch.\n'
        printf '\nWhich version of Wine would you like to install: [s]table, [d]evelopment, or\n[st]aging? '
        local wine_version
        read -r wine_version
        if [[ $wine_version =~ ^([sS][tT][aA][gG][iI][nN][gG]|[sS][tT])$ ]]; then
            wine_version="st"
            printf '\nSince Wine Staging is not in the official Debian repository, installing it\nwould mean you need to add the Wine HQ repository key and use that repository\nto install and update Wine. If you do not want to do this, you can choose to\ninstall the stable or development branch of Wine. Are you okay installing Wine\nStaging from the Wine HQ repository [y/n]? '
            local install_wine_staging
            read -r install_wine_staging
            if [[ $install_wine_staging =~ ^([nN][oO]|[nN])$ ]]; then
                printf '\nWould you like to install [s]table or [d]evelopment? '
                local wine_version_2
                read -r wine_version_2
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
        printf '\nIn order to install Wine, you need to enable multi-arch, which lets you install\nlibrary packages from multiple architectures on the same machine. Would you\nlike to do that now (you do not have to do this again if you have already done\nthis step when installing Steam) [y/n]? '
        local enable_multi_arch_2
        read -r enable_multi_arch_2
        if [[ $enable_multi_arch_2 =~ ^([yY][eE][sS]|[yY])$ ]]; then
            dpkg --add-architecture i386
            apt-get update
            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
        fi
        printf '\nWould you like to install the necessary Wine package now [y/n]? '
        local install_wine_package
        read -r install_wine_package
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
                    printf '\nAdd the following line to your /etc/apt/sources.list file:\n'
                    printf "\e[32m%s\e[0m\n" "deb https://dl.winehq.org/wine-builds/debian/ buster main"
                    printf 'Press enter once you have added this line. '
                    local added_winehq_repo
                    # shellcheck disable=SC2034  # Unused variable left for readability
                    read -r added_winehq_repo
                    apt update
                    apt install --install-recommends winehq-staging
                elif [ $debian_version = "bullseye/sid" ]; then
                    printf '\nAdd the following line to your /etc/apt/sources.list file:\n'
                    printf "\e[32m%s\e[0m\n" "deb https://dl.winehq.org/wine-builds/debian/ bullseye main"
                    printf 'Press enter once you have added this line. '
                    local added_winehq_repo
                    # shellcheck disable=SC2034  # Unused variable left for readability
                    read -r added_winehq_repo
                    apt update
                    apt install --install-recommends winehq-staging
                fi
                printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
            fi
            printf 'If these installations ran successfully, then you have setup Wine.\n'
        else
            printf '\nWine installation aborted.\n'
        fi
    fi
}

setup_wine_gui() {
    if zenity --width="$gui_width" --height="$gui_height" --question --text="Wine is a tool that allows you to run Windows applications on Linux. It is required for many applications such as Lutris. It is recommended that you install Wine, would you like to start the process of getting Wine installed now?"; then
        zenity --width="$gui_width" --height="$gui_height" --info --text="There are three main branches of Wine: Stable, Development, and Staging. Stable is, as the name implies, the most stable branch, with the least amount of features. Wine development is rapid, with new releases in the development branch every two weeks or so. Staging contains bug fixes and features which have not been integrated into the development branch yet. The idea of Wine Staging is to provide experimental features faster to end users and to give developers the possibility to discuss and improve their patches before they are integrated into the main branch."
        local wine_version
        wine_version="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Which version of Wine would you like to install?" --column="Wine Branch" "Stable" "Development" "Staging")"
        if [ "$wine_version" = "Staging" ]; then
            if ! zenity --width="$gui_width" --height="$gui_height" --question --text="Since Wine Staging is not in the official Debian repository, installing it would mean you need to add the Wine HQ repository key and use that repository to install and update Wine. If you do not want to do this, you can choose to install the stable or development branch of Wine. Are you okay installing Wine Staging from the Wine HQ repository?"; then
                local wine_version_2
                wine_version_2="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Would you like to install Stable or Development?" --column="Wine Branch" "Stable" "Development")"
                if [ "$wine_version_2" = "Stable" ]; then
                    wine_version="Stable"
                elif [ "$wine_version_2" = "Development" ]; then
                    wine_version="Development"
                fi
            fi
        fi
        if zenity --width="$gui_width" --height="$gui_height" --question --text="In order to install Wine, you need to enable multi-arch, which lets you install library packages from multiple architectures on the same machine. Would you like to do that now (you do not have to do this again if you have already done this step when installing Steam) [y/n]? "; then
            dpkg --add-architecture i386
            apt-get update
        fi
        if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to install the necessary Wine package now?"; then
            if [ "$wine_version" = "Stable" ]; then
                apt-get install wine
            elif [ "$wine_version" = "Development" ]; then
                apt-get install wine-development
            elif [ "$wine_version" = "Staging" ]; then
                wget -nc https://dl.winehq.org/wine-builds/winehq.key
                apt-key add winehq.key
                if [ "$debian_version" = "buster" ]; then
                    zenity --width="$gui_width" --height="$gui_height" --info --text="Add the following line to your /etc/apt/sources.list file:\ndeb https://dl.winehq.org/wine-builds/debian/ buster main\nPress enter once you have added this line."
                    apt update
                    apt install -install-recommends winehq-staging
                elif [ $debian_version = "bullseye/sid" ]; then
                    zenity --width="$gui_width" --height="$gui_height" --info --text="Add the following line to your /etc/apt/sources.list file:\ndeb https://dl.winehq.org/wine-builds/debian/ bullseye main\nPress enter once you have added this line."
                    apt update
                    apt install -install-recommends winehq-staging
                fi
            fi
            zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have setup Wine."
        else
            zenity --width="$gui_width" --height="$gui_height" --info --text="Wine installation aborted."
        fi
    fi
}

setup_lutris() {
    printf '\nLutris is a FOSS game manager for Linux-based operating systems. It uses Wine\nand other tools like DXVK to make managing and running games much easier on\nLinux. It is recommended that you install Lutris, would you like to start the\nprocess of getting Lutris installed now [y/n]? '
    local install_lutris
    read -r install_lutris
    if [[ $install_lutris =~ ^([yY][eE][sS]|[yY])$ ]]; then
        printf '\nLutris requires you have Wine installed on your system. If you do not have\nWine, you will not be able to continue with this installation process. Do you\nhave Wine installed on your system [y/n]? '
        local installed_wine
        read -r installed_wine
        if [[ $installed_wine =~ ^([yY][eE][sS]|[yY])$ ]]; then
            printf '\nLutris is not in the official Debian repository. According to the Lutris\nwebsite, the way to install Lutris from an auto-updating repository is using\nthe openSUSE Build Service Repository, which requires adding a key for this\nrepository. If this is not something you want to do, you can also download the\n.deb file from the openSUSE website and install Lutris using that, or download\nthe tar.xz package from Lutris and run the project directly from the extracted\narchive.\n'
            printf '\nWould you like to [1]use the openSUSE Build Service Repository, [2]download and\ninstall the .deb file from the openSUSE website, or [3]download the tar.xz\npackage from Lutris and run the project directly from the extracted archive? '
            local lutris_installation_choice
            read -r lutris_installation_choice
            if [ "$lutris_installation_choice" = "1" ]; then
                if [ $debian_version = "buster" ]; then
                    printf '\nWould you like to add the\nhttp://download.opensuse.org/repositories/home:/strycore/Debian_10/ repository\nand key to your apt sources, and install Lutris now [y/n]? '
                    local install_lutris_package
                    read -r install_lutris_package
                    if [[ $install_lutris_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
                        echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ /' >/etc/apt/sources.list.d/home:strycore.list
                        wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_10/Release.key -O Release.key
                        apt-key add - <Release.key
                        apt-get update
                        apt-get install lutris
                        printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                        printf 'If these installations ran successfully, then you have setup Lutris.\n'
                    else
                        printf '\nLutris installation aborted.\n'
                    fi
                elif [ $debian_version = "bullseye/sid" ]; then
                    printf '\nAre you running Debian [t]esting or [u]nstable? '
                    local testing_or_unstable
                    read -r testing_or_unstable
                    if [[ $testing_or_unstable =~ ^([tT][eE][sS][tT][iI][nN][gG]|[tT])$ ]]; then
                        printf '\nWould you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/\n repository and key to your apt sources, and install Lutris now [y/n]? '
                        local install_lutris_package
                        read -r install_lutris_package
                        if [[ $install_lutris_package =~ ^([yY][eE][sS]|[yY])$ ]]; then
                            echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/ /' >/etc/apt/sources.list.d/home:strycore.list
                            wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_Testing/Release.key -O Release.key
                            apt-key add - <Release.key
                            apt-get update
                            apt-get install lutris
                            printf "\e[33m%s\e[0m\n" "--------------------------------------------------------------------------------"
                            printf 'If these installations ran successfully, then you have setup Lutris.\n'
                        else
                            printf '\nLutris installation aborted.\n'
                        fi
                    elif [[ $testing_or_unstable =~ ^([uU][nN][sS][tT][aA][bB][lL][eE]|[uU])$ ]]; then
                        printf '\nWould you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/\n repository and key to your apt sources, and install Lutris now [y/n]? '
                        local install_lutris_package
                        read -r install_lutris_package
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
            elif [ "$lutris_installation_choice" = "2" ]; then
                printf '\nYou can download the Lutris .deb file for your version of Debian directly from\nthe openSUSE build service site here:\nhttps://software.opensuse.org/download.html?project=home%%3Astrycore&package=lutris\n'
                printf '\nGo to the link, click "Grab binary packages directly", and download the Lutris\n.deb file for your version of Debian.\n'
                printf 'Navigate to the directory where you downloaded the .deb file, and install it by\nrunning the following command (replacing the version number with the version\nyou downloaded):\n'
                printf "\e[32m%s\e[0m\n" "sudo apt install ./lutris_0.5.6_amd64"
            elif [ "$lutris_installation_choice" = "3" ]; then
                printf '\nYou can download the tar.xz package from Lutris and run the project directly\nfrom the extracted archive. To do that, go to the Lutris download page here:\nhttps://lutris.net/downloads/, navigate to the "Tarball" section, and follow\nthe instructions there.\n'
            fi
        fi
    fi
}

setup_lutris_gui() {
    if zenity --width="$gui_width" --height="$gui_height" --question --text="Lutris is a FOSS game manager for Linux-based operating systems. It uses Wine and other tools like DXVK to make managing and running games much easier on Linux. It is recommended that you install Lutris, would you like to start the process of getting Lutris installed now?"; then
        if zenity --width="$gui_width" --height="$gui_height" --question --text="Lutris requires you have Wine installed on your system. If you do not have Wine, you will not be able to continue with this installation process. Do you have Wine installed on your system?"; then
            zenity --width="$gui_width" --height="$gui_height" --info --text="Lutris is not in the official Debian repository. According to the Lutris website, the way to install Lutris from an auto-updating repository is using the openSUSE Build Service Repository, which requires adding a key for this repository. If this is not something you want to do, you can also download the .deb file from the openSUSE website and install Lutris using that, or download the tar.xz package from Lutris and run the project directly from the extracted archive."
            local lutris_installation_choice
            lutris_installation_choice="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="How would you like to install Lutris?" --column="Lutris Installation" "Use the openSUSE Build Service Repository" "Download and install the .deb file from the openSUSE website" "Download the tar.xz package from Lutris and run the project directly")"
            if [ "$lutris_installation_choice" = "Use the openSUSE Build Service Repository" ]; then
                if [ "$debian_version" = "buster" ]; then
                    if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_10/ repository and key to your apt sources, and install Lutris now?"; then
                        echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ /' >/etc/apt/sources.list.d/home:strycore.list
                        wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_10/Release.key -O Release.key
                        apt-key add - <Release.key
                        apt-get update
                        apt-get install lutris
                        zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have setup Lutris."
                    else
                        zenity --width="$gui_width" --height="$gui_height" --info --text="Lutris installation aborted."
                    fi
                elif [ $debian_version = "bullseye/sid" ]; then
                    local testing_or_unstable
                    testing_or_unstable="$(zenity --width="$gui_width" --height="$gui_list_height" --list --title="Are you running Debian Testing or Unstable?" --column="Debian Version" "Testing" "Unstable")"
                    if [ "$testing_or_unstable" = "Testing" ]; then
                        if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/ repository and key to your apt sources, and install Lutris now?"; then
                            echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/ /' >/etc/apt/sources.list.d/home:strycore.list
                            wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_Testing/Release.key -O Release.key
                            apt-key add - <Release.key
                            apt-get update
                            apt-get install lutris
                            zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have setup Lutris."
                        else
                            zenity --width="$gui_width" --height="$gui_height" --info --text="Lutris installation aborted."
                        fi
                    elif [ "$testing_or_unstable" = "Unstable" ]; then
                        if zenity --width="$gui_width" --height="$gui_height" --question --text="Would you like to add the http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/ repository and key to your apt sources, and install Lutris now?"; then
                            echo 'deb http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/ /' >/etc/apt/sources.list.d/home:strycore.list
                            wget -nv https://download.opensuse.org/repositories/home:strycore/Debian_Unstable/Release.key -O Release.key
                            apt-key add - <Release.key
                            apt-get update
                            apt-get install lutris
                            zenity --width="$gui_width" --height="$gui_height" --info --text="If these installations ran successfully, then you have setup Lutris."
                        else
                            zenity --width="$gui_width" --height="$gui_height" --info --text="Lutris installation aborted."
                        fi
                    fi
                fi
            elif [ "$lutris_installation_choice" = "Download and install the .deb file from the openSUSE website" ]; then
                zenity --width="$gui_width" --height="$gui_height" --info --text="You can download the Lutris .deb file for your version of Debian directly from the openSUSE build service site here:\nhttps://software.opensuse.org/download.html?project=home%3Astrycore&amp;package=lutris\nGo to the link, click 'Grab binary packages directly', and download the Lutris .deb file for your version of Debian. Navigate to the directory where you downloaded the .deb file, and install it by running the following command (replacing the version number with the version you downloaded):\nsudo apt install ./lutris_0.5.6_amd64"
            elif [ "$lutris_installation_choice" = "Download the tar.xz package from Lutris and run the project directly" ]; then
                zenity --width="$gui_width" --height="$gui_height" --info --text="You can download the tar.xz package from Lutris and run the project directly from the extracted archive. To do that, go to the Lutris download page here: https://lutris.net/downloads/, navigate to the 'Tarball' section, and follow the instructions there."
            fi
        fi
    fi
}

# Help flag
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    printf "Usage: debian-gaming-setup [OPTIONS]\n\n"
    printf "       Starts an interactive shell script for installing recommended\n"
    printf "       tools to game efficiently on Debian.\n\n"
    printf "Options:\n"
    printf "       -h, --help       Show help options\n"
    printf "       -g, --gui        Run using the built-in GUI\n"
    exit 0
fi

gui=false
# GUI flag
if [ "$1" = "-g" ] || [ "$1" = "--gui" ]; then
    if ! (zenity --version) >/dev/null 2>&1; then
        printf 'The zenity package is required to run with the gui flag.\nPlease install zenity by running:\nsudo apt install zenity\nAnd try again.\n'
        exit 1
    fi
    gui=true
    gui_width=500
    gui_height=100
    gui_list_height=300
fi

if [ $gui = true ]; then
    zenity --width="$gui_width" --height="$gui_height" --info --text="This script will help you get all the tools you need to start gaming on Debian."
else
    printf 'This script will help you get all the tools you need to start gaming on Debian.\n'
fi

# Grab Debian version
debian_version=$(cat /etc/debian_version)
if [[ $debian_version == *"10"* ]]; then
    debian_version="buster"
fi

if [ $gui = true ]; then
    confirm_debian_version_gui
else
    confirm_debian_version
fi

# Grab graphics card
gpu=""
if [ $gui = true ]; then
    grab_graphics_card_gui
else
    grab_graphics_card
fi

# Install graphics drivers
if [ $gui = true ]; then
    zenity --width="$gui_width" --height="$gui_height" --info --text="To get the best gaming performance you should install the latest graphics drivers."
else
    printf '\nTo get the best gaming performance you should install the latest graphics\ndrivers.\n'
fi

# Nvidia drivers
if [ "$gpu" = "Nvidia" ]; then
    if [ $gui = true ]; then
        install_nvidia_tools_gui
    else
        install_nvidia_tools
    fi
# AMD drivers
elif [ "$gpu" = "AMD" ]; then
    if [ $gui = true ]; then
        install_amd_tools_gui
    else
        install_amd_tools
    fi
else
    printf '\nError: invalid gpu variable assignment, exiting...'
    exit 1
fi

# Steam installation
if [ $gui = true ]; then
    setup_steam_gui
else
    setup_steam
fi

# Wine installation
if [ $gui = true ]; then
    setup_wine_gui
else
    setup_wine
fi

# Lutris installation
if [ $gui = true ]; then
    setup_lutris_gui
else
    setup_lutris
fi

if [ $gui = true ]; then
    zenity --width="$gui_width" --height="$gui_height" --info --text="If all these installations ran successfully, then you have setup all the recommended tools to get started gaming on Debian."
else
    printf '\nIf all these installations ran successfully, then you have setup all the recommended\ntools to get started gaming on Debian.\n'
fi
exit 0
