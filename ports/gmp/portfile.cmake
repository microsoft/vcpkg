## requires AUTOCONF, LIBTOOL and PKCONF


# if(VCPKG_TARGET_IS_WINDOWS)
    # vcpkg_check_linkage(ONLY_STATIC_LIBRARY) 
    # #set(OPTIONS --disable-assembler)
# endif()
vcpkg_download_distfile(
    ARCHIVE
    URLS https://gmplib.org/download/gmp/gmp-6.2.0.tar.xz 
    FILENAME gmp-6.2.0.tar.xz
    SHA512 a066f0456f0314a1359f553c49fc2587e484ff8ac390ff88537266a146ea373f97a1c0ba24608bf6756f4eab11c9056f103c8deb99e5b57741b4f7f0ec44b90c)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF gmp-6.2.0
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    #SKIP_CONFIGURE
    #NO_DEBUG
    #AUTO_HOST
    #AUTO_DST
    #PRERUN_SHELL ${SHELL_PATH}
    OPTIONS ${OPTIONS}
    #OPTIONS_DEBUG
    #OPTIONS_RELEASE
    PKG_CONFIG_PATHS_RELEASE "${CURRENT_INSTALLED_DIR}/lib/pkgconfig"
    PKG_CONFIG_PATHS_DEBUG "${CURRENT_INSTALLED_DIR}/debug/lib/pkgconfig"
)

vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# # Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYINGv3" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

endif()


