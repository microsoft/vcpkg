#Still a TODO Build_Depends is wrong
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libevdev/libevdev
    REF  468760ba11438734912f793b1de00cb0f243497f 
    SHA512 6662258e0a6fcc602c6df34428fc4e268cc2982d6cbc45bcd54944ce7cd986737fd1c232c299028d0d8bdd63d935192475f1a650d2bc69f819d892ee0e3e9b12
    HEAD_REF master # branch name
    #PATCHES ${PATCHES} #patch name
) 

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -Dtests=disabled
            -Ddocumentation=disabled

)
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)




