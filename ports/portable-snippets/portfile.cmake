include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/portable-snippets
    REF 77654dbc376e0465aaae096553eeb2e95a9f2735
    SHA512 e73da06f0d90e303250481de1b3a23dcf872b492b7b2b4baa040b24d152d492aa1ae0c455a9aaea2e87a687e65913db2cb7796b6fafb0c3a5c0f0a705d14503c
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DPSNIP_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DPSNIP_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME unofficial-${PORT})
