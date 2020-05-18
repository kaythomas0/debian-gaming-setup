#!/usr/bin/env ./test/libs/bats-core/bin/bats
load 'libs/bats-support/load'
load 'libs/bats-assert/load'

profile_script="./debian-gaming-setup"

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
    skip
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

@test "install_nvidia_tools correctly installs nvidia tools using buster-backports, automatic apt modification, and nvidia-driver" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "yes"; echo "automatically"; echo "yes"; echo "no"; echo "yes"; echo "yes"; echo "1"; echo "yes"; } | install_nvidia_tools)"
    assert_success
    assert_output --partial "Okay, you are running an AMD graphics card."
}
