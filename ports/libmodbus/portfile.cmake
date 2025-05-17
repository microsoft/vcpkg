vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stephane/libmodbus
    REF "v${VERSION}"
    SHA512 6a01da1f8b486e356ff44874f1479d9d121463958a5ed06e60d910328ccc9b2d431b4a1fd72861c5c645c97b5887a076b763ad6a9ae6b18402dd043ec525b1e2
    HEAD_REF master
)

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
    OPTIONS
        --enable-tests=no
)
vcpkg_make_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
file(COPY "${CURRENT_PORT_DIR}/libmodbusConfig.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/libmodbus")

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libmodbus.pc" " -lmodbus" " -lmodbus -lws2_32")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmodbus.pc" " -lmodbus" " -lmodbus -lws2_32")
    endif()
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LESSER")