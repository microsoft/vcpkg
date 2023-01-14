# header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jamesdbrock/hffix
    REF v1.0.0
    SHA512 0043b789e6ffdc32eaf2736a8621dd7fd54e1a16aae33bb1d5f642da1b04d150ed42d8f9ddd046013242164854d9091540452153f09459d05f9bf4a186c7b860
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)