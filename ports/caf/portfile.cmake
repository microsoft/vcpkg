vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF bac5b8b24a62ff2a818de1b08f6f31f897e42222 # 0.19.1
    SHA512 c61f3cce4d4707f19db8c1b1a8b2c4655335a7a29c77a0c9692775c9fcdc90d6dce75d3122804c31cf66c47f37d3a3674ad18df67d1204c7f52eb4740ff766af
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
