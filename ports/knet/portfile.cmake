vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kibaamor/knet
    REF v1.0.2
    SHA512 fb101d10d3bb08e565618923a10bc39586a934ae562ba7241c079f781baaafbc511e0bd2de13db6263246dede5e602d578e1fbdf45c84a6fecc4d3ddad4735e9
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DKNET_BUILD_EXAMPLE:BOOL=OFF
        -DKNET_BUILD_TEST:BOOL=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/knet TARGET_PATH share/knet)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
