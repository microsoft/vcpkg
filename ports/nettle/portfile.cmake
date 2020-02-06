set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

## requires AUTOCONF, LIBTOOL and PKCONF
message(STATUS "----- ${PORT} requires autoconf, libtool and pkconf from the system package manager! \n ----- sudo apt-get install autogen autoconf libtool-----")

vcpkg_from_gitlab(
    GITLAB_URL https://git.lysator.liu.se/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nettle/nettle
    REF  ee5d62898cf070f08beedc410a8d7c418588bd95 #v3.5.1 
    SHA512 881912548f4abb21460f44334de11439749c8a055830849a8beb4332071d11d9196d9eecaeba5bf822819d242356083fba91eb8719a64f90e41766826e6d75e1
    HEAD_REF master # branch name
    #PATCHES example.patch #patch name
) 

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    OPTIONS
        --disable-documentation
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share/)

# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
# # Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME Xlib)
