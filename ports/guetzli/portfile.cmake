include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/guetzli
    REF 0b78c7cc8b1b6cbaaf3d08b1facb599bcec1d101
    SHA512 54c5198c4c066858dd1377a32e765f46a589f3444bea303b54326453d0e8e71f959d3aaf2c72f4714fd27891f4d93288e7fa96baf1fd10f127929c1fcfa5ae1c
    HEAD_REF master
    PATCHES butteraugli.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON -DDISABLE_INSTALL_TOOLS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/guetzli)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/guetzli RENAME copyright)
