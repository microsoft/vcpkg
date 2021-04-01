vcpkg_fail_port_install(ON_TARGET "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(BUILD_TESTS OFF)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hrantzsch/keychain
    REF v1.2.0
    SHA512 8faed892e6d84ad3d31056682dc4bb18ff8c12a3eababfa58e3c01ad369da1d9b0772198e15196b49b4de895a44ff7e96a59b56b87011f95ec88bcae819fe6ff
)

if(VCPKG_TARGET_IS_LINUX)
    if (NOT EXISTS "/usr/include/libsecret-1/libsecret/secret.h")
        message(FATAL_ERROR "keychain requires libsecret-1-dev, please use your distribution's package manager to install it.\n"
                            "Debian/Ubuntu: sudo apt-get install libsecret-1-dev\n"
                            "Red Hat/CentOS/Fedora: sudo yum install libsecret-devel\n"
                            "Arch Linux: sudo pacman -Sy libsecret\n")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH} 
    PREFER_NINJA 
    DISABLE_PARALLEL_CONFIGURE 
    OPTIONS -DBUILD_TESTS:BOOL=${BUILD_TESTS}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
