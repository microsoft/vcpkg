vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kibaamor/knet
    REF v1.0.3
    SHA512 8bc4fb43b456d86ecae939cfae539432bde1f7ad2261abf9a7654d7476eb6502f53cd314f21dd23f77eb8d2969d293f6cb886729c688ea25911157c7fa3c8b7c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
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
