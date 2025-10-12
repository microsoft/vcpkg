vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF "${VERSION}"
    SHA512 64e504513694b351eec954baae4c243dc3d273cc893094548be31131abfc5bd4eb3968ab6326b26d1b9de8454c1511104a46a4e81c9ff73f54028592abc9f410
    HEAD_REF main
    PATCHES
        fix_dependency.patch
        fix_cxx17.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCAF_ENABLE_CURL_EXAMPLES=OFF
        -DCAF_ENABLE_PROTOBUF_EXAMPLES=OFF
        -DCAF_ENABLE_QT6_EXAMPLES=OFF
        -DCAF_ENABLE_RUNTIME_CHECKS=OFF
        -DCAF_ENABLE_ACTOR_PROFILER=OFF
        -DCAF_ENABLE_EXAMPLES=OFF
        -DCAF_ENABLE_TESTING=OFF
        -DCAF_ENABLE_IO_MODULE=ON
        -DCAF_ENABLE_EXCEPTIONS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME CAF CONFIG_PATH lib/cmake/CAF)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/caf/internal")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
