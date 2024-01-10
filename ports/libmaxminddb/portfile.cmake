vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO maxmind/libmaxminddb
    REF "${VERSION}"
    SHA512 0fc69bb09b74b892317c64d11822e29311e016566b60fc217efb20aec713e29dc02400839497cfcf5e837fcee9efa3536452997fa76bbc23464fad92a5a89bef
    HEAD_REF main
    PATCHES fix-lib-to-share.patch
)

#file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_SHARED_LIBRARY_PREFIX=lib
        -DCMAKE_STATIC_LIBRARY_PREFIX=lib
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
#vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)