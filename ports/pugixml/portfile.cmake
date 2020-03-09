include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/pugixml
    REF v1.10
    SHA512 0634053d4f757b9293997763bb2e51595197c192f3974e954975d6d6ff91e4a6cb7c194efa530e0eef1a2a93db16592c5630010b6482430dff5ffc6879e84b6a
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DUSE_POSTFIX=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/pugixml)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/pugixml RENAME copyright)
