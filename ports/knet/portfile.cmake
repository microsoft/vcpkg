vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kibaamor/knet
    REF v1.1.0
    SHA512 22f46c2626c60798a99d7fe3027b675d40584df141fc1131a0d737df28f3e633ec798567defd131b08c3b3ec81069648ed45c2e37eacf37dc15ead45ab24ee55
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DKNET_ENABLE_LOG=OFF
        -DKNET_SOCKET_STAT=OFF
        -DKNET_BUILD_EXAMPLE=OFF
        -DKNET_BUILD_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/knet)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
