if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libprotobuf-mutator
    REF "v${VERSION}"
    SHA512 9c752cf2bdbf9228ba5a7c1e7a552ea7e12bda226ad8268e4cb9f135a79aee9c3ff0c1f2dfebe5d011282835a63d3b9cf3b3f642f02a3e00bb0b5eee9580a3dd
    HEAD_REF master
    PATCHES
        protobuf-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_RUNTIME)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIB_PROTO_MUTATOR_TESTING=OFF
        -DLIB_PROTO_MUTATOR_MSVC_STATIC_RUNTIME=${STATIC_RUNTIME}
        -DPKG_CONFIG_PATH=lib/pkgconfig
    MAYBE_UNUSED_VARIABLES
        LIB_PROTO_MUTATOR_MSVC_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
