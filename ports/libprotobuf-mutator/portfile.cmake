if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/libprotobuf-mutator
    REF "v${VERSION}"
    SHA512 7a5e0700a2bb1bcff7a43593ec3908ffc204a936536cb88e5f37858721659c3ebbb495eb0121362b6b87436cebfe3c3732d05f4a8b5eb39dc346997ca10f4dc3
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
