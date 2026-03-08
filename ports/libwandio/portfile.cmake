if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    set(PATCHES curl.patch)
    #TODO: Still does not work. Requires proper "signal" support and "unistd"
else()
    set(PATCHES openssl.patch) # needed if curl is using openssl
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wanduow/wandio
    REF ${VERSION}
    SHA512 931bdfe91c8923de52217873d5a12568bcac97b2ab7e4e50f48cd9999d7b3887175885c3f56250b0cd822584bbf4a9262b017ab57ed599ddd288abda1fad9885
    HEAD_REF master
    PATCHES configure.lib.patch # This is how configure.ac files with dependencies get fixed. 
            configure.patch
            ${PATCHES}
)

if (VCPKG_TARGET_IS_ANDROID)
    list(APPEND OPTIONS ac_cv_func_malloc_0_nonnull=yes)
    list(APPEND OPTIONS ac_cv_func_realloc_0_nonnull=yes)
endif()

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
    OPTIONS
        ${OPTIONS}
)
vcpkg_install_make()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
