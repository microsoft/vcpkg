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
    REF 012b646e7ba7ab191a5a2206488adfac493fcdc6
    SHA512 e94a82038902c34933c4256f8bd4d7ef3f2cf32fea46f8e31a25df34cc90d3a275ff56d3bc9892aca0c85e6d875e696f96a836cc1444fe165db8364331e6e77d
    HEAD_REF master
    PATCHES configure.lib.patch # This is how configure.ac files with dependencies get fixed. 
            configure.patch
            ${PATCHES}
)

vcpkg_configure_make(
    AUTOCONFIG
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
)
vcpkg_install_make()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
