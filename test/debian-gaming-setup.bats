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
    # Don't update kernel headers, get to the step right before installing nvidia-driver
    output="$({ echo "yes"; echo "automatically"; echo "yes"; echo "no"; echo "no"; echo "1"; echo "yes"; echo "yes"; echo "n"; } | install_nvidia_tools)"
    assert_success
    assert_output --partial "necessary Nvidia graphics drivers."
    unset debian_version
}

@test "install_amd_tools gets to install drivers step" {
    export debian_version="buster"
    source ${profile_script}
    output="$({ echo "skip"; echo "yes"; echo "yes"; echo "n"; echo "n"; } | install_amd_tools)"
    assert_success
    assert_output --partial "necessary AMD graphics drivers."
    unset debian_version
}

@test "setup_steam" {
    export gpu="Nvidia"
    source ${profile_script}
    output="$({ echo "y"; echo "y"; echo "y"; echo "y"; echo "y"; } | setup_steam)"
    assert_success
    assert_output --partial "necessary AMD graphics drivers."
    unset gpu
}
