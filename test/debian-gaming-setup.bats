#!/usr/bin/env ./test/libs/bats-core/bin/bats

load 'libs/bats-support/load'
load 'libs/bats-assert/load'

profile_script="./debian-gaming-setup"

setup_bullseye_sources_file() {
    echo 'deb http://deb.debian.org/debian bullseye main' >/etc/apt/sources.list
    echo 'deb http://security.debian.org/debian-security bullseye/updates main' >>/etc/apt/sources.list
    echo 'deb http://deb.debian.org/debian bullseye-updates main' >>/etc/apt/sources.list
}

setup_sid_sources_file() {
    echo 'deb http://deb.debian.org/debian sid main' >/etc/apt/sources.list
    echo 'deb http://security.debian.org/debian-security sid/updates main' >>/etc/apt/sources.list
    echo 'deb http://deb.debian.org/debian sid-updates main' >>/etc/apt/sources.list
}

reset_sources_file() {
    echo 'deb http://deb.debian.org/debian buster main' >/etc/apt/sources.list
    echo 'deb http://security.debian.org/debian-security buster/updates main' >>/etc/apt/sources.list
    echo 'deb http://deb.debian.org/debian buster-updates main' >>/etc/apt/sources.list
}

setup_file() {
    reset_sources_file
}

@test "confirm_debian_version confirms buster version" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; } | confirm_debian_version)"
    assert_success
    assert_output --partial "It looks like your version of Debian is buster."
    unset debian_version
}

@test "confirm_debian_version confirms bullseye/sid version" {
    export debian_version="bullseye/sid"
    source ${profile_script}
    output="$({ echo "yes"; } | confirm_debian_version)"
    assert_success
    assert_output --partial "It looks like your version of Debian is bullseye/sid."
    unset debian_version
}

@test "confirm_debian_version allows choice of stable version" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "no"; echo "stable"; } | confirm_debian_version)"
    assert_success
    assert_output --partial "Okay, you are running buster."
    unset debian_version
}

@test "confirm_debian_version allows choice of testing version" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "no"; echo "testing"; } | confirm_debian_version)"
    assert_success
    assert_output --partial "Okay, you are running bullseye/sid."
    unset debian_version
}

@test "confirm_debian_version allows choice of unstable version" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "no"; echo "unstable"; } | confirm_debian_version)"
    assert_success
    assert_output --partial "Okay, you are running bullseye/sid."
    unset debian_version
}

@test "grab_graphics_card allows choice of nvidia gpu" {
    source ${profile_script}
    output="$({ echo "nvidia"; } | grab_graphics_card)"
    assert_success
    assert_output --partial "Okay, you are running an Nvidia graphics card."
}

@test "grab_graphics_card allows choice of amd gpu" {
    source ${profile_script}
    output="$({ echo "amd"; } | grab_graphics_card)"
    assert_success
    assert_output --partial "Okay, you are running an AMD graphics card."
}

@test "grab_graphics_card detects a gpu if pciutils is installed" {
    apt-get -y update
    apt-get -y install pciutils
    source ${profile_script}
    if ! [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [nN][vV][iI][dD][iI][aA] ]] && ! [[ "$(lspci | grep -i 'vga\|3d\|2d')" =~ [aA][mM][dD] ]]; then
        output="$({ echo "amd"; } | grab_graphics_card)"
        assert_success
        assert_output --partial "Okay, you are running an AMD graphics card."
    else
        output="$({ echo "yes"; } | grab_graphics_card)"
        assert_success
        assert_output --partial "graphics card detected."
    fi
}

@test "install_nvidia_tools gets to install drivers step" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; echo "automatically"; echo "yes"; echo "no"; echo "no"; echo "1"; echo "yes"; echo "yes"; echo "no"; } | install_nvidia_tools)"
    assert_success
    assert_output --partial "necessary Nvidia graphics drivers."
    unset debian_version
}

@test "install_nvidia_tools automatically modifies buster sources.list correctly" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; echo "automatically"; } | install_nvidia_tools)"
    grep -q "deb http://deb.debian.org/debian buster-backports main contrib non-free" "/etc/apt/sources.list"
    grep -q "deb http://deb.debian.org/debian buster main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_nvidia_tools automatically modifies bullseye sources.list correctly" {
    export debian_version="bullseye/sid"
    setup_bullseye_sources_file
    source ${profile_script}
    output="$({ echo "automatically"; echo "testing"; } | install_nvidia_tools)"
    grep -q "deb http://deb.debian.org/debian bullseye main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_nvidia_tools automatically modifies sid sources.list correctly" {
    export debian_version="bullseye/sid"
    setup_sid_sources_file
    source ${profile_script}
    output="$({ echo "automatically"; echo "unstable"; } | install_nvidia_tools)"
    grep -q "deb http://deb.debian.org/debian sid main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_nvidia_tools correctly shows manual steps to modify backports sources.list" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; echo "manually"; } | install_nvidia_tools)"
    assert_output --partial "deb http://deb.debian.org/debian buster-backports main contrib non-free"
    assert_output --partial "deb http://deb.debian.org/debian buster main contrib non-free"
    unset debian_version
}

@test "install_nvidia_tools correctly shows manual steps to modify buster sources.list" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "no"; echo "manually"; } | install_nvidia_tools)"
    assert_output --partial "deb http://deb.debian.org/debian buster main contrib non-free"
    unset debian_version
}

@test "install_nvidia_tools correctly shows manual steps to modify bullseye/sid sources.list" {
    export debian_version="bullseye/sid"
    source ${profile_script}
    output="$({ echo "manually"; } | install_nvidia_tools)"
    assert_output --partial "deb http://deb.debian.org/debian bullseye main contrib non-free"
    assert_output --partial "deb http://deb.debian.org/debian sid main contrib non-free"
    unset debian_version
}

@test "install_amd_tools gets to install drivers step" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "skip"; echo "yes"; echo "yes"; echo "no"; echo "no"; } | install_amd_tools)"
    assert_success
    assert_output --partial "necessary AMD graphics drivers."
    unset debian_version
}

@test "install_amd_tools automatically modifies buster sources.list correctly" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "automatically"; } | install_amd_tools)"
    grep -q "deb http://deb.debian.org/debian buster main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_amd_tools automatically modifies bullseye sources.list correctly" {
    export debian_version="bullseye/sid"
    setup_bullseye_sources_file
    source ${profile_script}
    output="$({ echo "automatically"; echo "testing"; } | install_amd_tools)"
    grep -q "deb http://deb.debian.org/debian bullseye main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_amd_tools automatically modifies sid sources.list correctly" {
    export debian_version="bullseye/sid"
    setup_sid_sources_file
    source ${profile_script}
    output="$({ echo "automatically"; echo "unstable"; } | install_amd_tools)"
    grep -q "deb http://deb.debian.org/debian sid main contrib non-free" "/etc/apt/sources.list"
    assert_success
    reset_sources_file
    unset debian_version
}

@test "install_amd_tools correctly shows manual steps to modify buster sources.list" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "manually"; } | install_amd_tools)"
    assert_output --partial "deb http://deb.debian.org/debian buster main contrib non-free"
    unset debian_version
}

@test "install_amd_tools correctly shows manual steps to modify bullseye/sid sources.list" {
    export debian_version="bullseye/sid"
    source ${profile_script}
    output="$({ echo "manually"; } | install_amd_tools)"
    assert_output --partial "deb http://deb.debian.org/debian bullseye main contrib non-free"
    assert_output --partial "deb http://deb.debian.org/debian sid main contrib non-free"
    unset debian_version
}

@test "setup_steam gets to install steam step" {
    export gpu="Nvidia"
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "yes"; echo "yes"; } | setup_steam)"
    assert_success
    assert_output --partial "Would you like to install the steam package now"
    unset gpu
}

@test "setup_wine installs wine stable" {
    source ${profile_script}
    output="$({ echo "yes"; echo "stable"; echo "no"; echo "yes"; echo "yes"; } | setup_wine)"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Wine."
}

@test "setup_wine installs wine development" {
    source ${profile_script}
    output="$({ echo "yes"; echo "development"; echo "no"; echo "yes"; echo "yes"; } | setup_wine)"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Wine."
}

@test "setup_wine installs wine staging for buster" {
    export debian_version="buster"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "staging"; echo "yes"; echo "no"; echo "yes"; echo "yes"; } | setup_wine)"
    grep -q "deb https://dl.winehq.org/wine-builds/debian/ buster main" "/etc/apt/sources.list"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Wine."
    unset debian_version
}

@test "setup_wine installs wine staging for bullseye/sid" {
    export debian_version="bullseye/sid"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "staging"; echo "yes"; echo "no"; echo "yes"; echo "yes"; } | setup_wine)"
    grep -q "deb https://dl.winehq.org/wine-builds/debian/ bullseye main" "/etc/apt/sources.list"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Wine."
    unset debian_version
}

@test "setup_wine gives proper notice for how wine staging works" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; echo "staging"; echo "no"; } | setup_wine)"
    assert_success
    assert_output --partial "Since Wine Staging is not in the official Debian repository"
    assert_output --partial "Would you like to install [s]table or [d]evelopment?"
    unset debian_version
}

@test "setup_lutris gets to install lutris step for buster" {
    export debian_version="buster"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "1"; echo "yes"; echo "yes"; } | setup_lutris)"
    grep -q "deb http://download.opensuse.org/repositories/home:/strycore/Debian_10/ /" "/etc/apt/sources.list.d/home:strycore.list"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Lutris."
    unset debian_version
}

@test "setup_lutris gets to install lutris step for bullseye" {
    export debian_version="bullseye/sid"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "1"; echo "testing"; echo "yes"; echo "yes"; } | setup_lutris)"
    grep -q "deb http://download.opensuse.org/repositories/home:/strycore/Debian_Testing/ /" "/etc/apt/sources.list.d/home:strycore.list"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Lutris."
    unset debian_version
}

@test "setup_lutris gets to install lutris step for sid" {
    export debian_version="bullseye/sid"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "1"; echo "unstable"; echo "yes"; echo "yes"; } | setup_lutris)"
    grep -q "deb http://download.opensuse.org/repositories/home:/strycore/Debian_Unstable/ /" "/etc/apt/sources.list.d/home:strycore.list"
    assert_success
    assert_output --partial "If these installations ran successfully, then you have setup Lutris."
    unset debian_version
}

@test "setup_lutris shows instructions for .deb download" {
    export debian_version="buster"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "2"; } | setup_lutris)"
    assert_success
    assert_output --partial "You can download the Lutris .deb file for your version of Debian directly"
    unset debian_version
}

@test "setup_lutris shows instructions for tar.xz download" {
    export debian_version="buster"
    apt-get -y install wget
    source ${profile_script}
    output="$({ echo "yes"; echo "yes"; echo "3"; } | setup_lutris)"
    assert_success
    assert_output --partial "You can download the tar.xz package from Lutris and run the project directly"
    unset debian_version
}
