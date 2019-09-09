include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artpaul/clickhouse-cpp
    REF 3b1e9964dad42fec1f131ede271b49d8ed2a517e
    SHA512 29a917347a03bcddfd29f69a2425d2296e0babeddf509be2d75a45f978ae6a0a29268cc08efdeb011e7a3f00d54229a2529a7a38198e41b6494078165952b757
    HEAD_REF master
    PATCHES 00001-fix-build.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/cmake/clickhouse-cpp)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/clickhouse-cpp/copyright COPYONLY)
