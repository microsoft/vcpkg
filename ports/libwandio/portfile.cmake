#vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux and Mac platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wanduow/wandio
    REF 012b646e7ba7ab191a5a2206488adfac493fcdc6
    SHA512 e94a82038902c34933c4256f8bd4d7ef3f2cf32fea46f8e31a25df34cc90d3a275ff56d3bc9892aca0c85e6d875e696f96a836cc1444fe165db8364331e6e77d
    HEAD_REF master
)

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    COPY_SOURCE
)
vcpkg_install_make()
#vcpkg_fixup_pkgconfig()?
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
