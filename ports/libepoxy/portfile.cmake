vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
if(NOT CMAKE_HOST_WIN32)
message("${PORT} currently requires the following tools from the system package manager:
    xutils-dev
    libegl1-mesa-dev
This can be installed on Ubuntu systems via apt-get install xutils-dev libegl1-mesa-dev")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anholt/libepoxy
    REF 1.5.4
    SHA512 c8b03f0a39df320fdd163a34c35f9ffbed51bc0174fd89a7dc4b3ab2439413087e1e1a2fe57418520074abd435051cbf03eb2a7bf8897da1712bbbc69cf27cc5
    HEAD_REF master
    PATCHES
        # https://github.com/anholt/libepoxy/pull/220
        libepoxy-1.5.4_Add_call_convention_to_mock_function.patch
)

if (VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_OSX)
    vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -Denable-glx=no
            -Denable-egl=no)
    vcpkg_install_meson()
    vcpkg_copy_pdbs()
else()
    vcpkg_configure_make(
        AUTOCONFIG
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            --enable-x11=yes
            --enable-glx=yes
            --enable-egl=yes
    )

    vcpkg_install_make()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
