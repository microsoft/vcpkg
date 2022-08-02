vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO actor-framework/actor-framework
    REF bfa0f83dd5c9151c263c304300c79161ae8cb595 # 0.18.6
    SHA512 58ebd40623edc0245dd38b3a2bbbda7af7d9b030155746949dfe7c4c30bdc07ee2ee84d195dc2e914d69f58c6c46bc9ad496bbc34e7cafe0530200458a4c5a76
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
