include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artpaul/clickhouse-cpp
    REF 1634d8b9e2f3183de1574344563d90557be3b305
    SHA512 bef74f624c2a777f8ec6b7e87ac3cc564e914bcecc639b3889695da56be4c90531309a8fd87054c2777580c36bc3b2d6e9c5690a6345018bf65a5294eeeb3390
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
