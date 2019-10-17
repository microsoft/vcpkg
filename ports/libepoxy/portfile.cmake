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
    REF 1.5.3
    SHA512 e831f4f918f08fd5f799501efc0e23b8d404478651634f5e7b35f8ebcc29d91abc447ab20da062dde5be75e18cb39ffea708688e6534f7ab257b949f9c53ddc8
    HEAD_REF master)


if (VCPKG_TARGET_IS_WINDOWS)
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
