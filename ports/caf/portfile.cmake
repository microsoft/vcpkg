vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF "${VERSION}"
    SHA512 97766b5b0a4db96b03be77c1ffd2198cc5536c09e2a06bb6fcff023ee78692f2c23ad213dc9698d6abfe950c61c4a2565bbfdfe871652cef816829e83d16ceab
    HEAD_REF master
    PATCHES
        fix_dependency.patch
        fix_cxx17.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DCAF_ENABLE_CURL_EXAMPLES=OFF
        -DCAF_ENABLE_PROTOBUF_EXAMPLES=OFF
        -DCAF_ENABLE_QT6_EXAMPLES=OFF
        -DCAF_ENABLE_RUNTIME_CHECKS=OFF
        -DCAF_ENABLE_ACTOR_PROFILER=OFF
        -DCAF_ENABLE_EXAMPLES=OFF
        -DCAF_ENABLE_TESTING=OFF
        -DCAF_ENABLE_TOOLS=OFF
        -DCAF_ENABLE_IO_MODULE=ON
        -DCAF_ENABLE_EXCEPTIONS=ON
        -DCAF_ENABLE_UTILITY_TARGETS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME CAF CONFIG_PATH lib/cmake/CAF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
