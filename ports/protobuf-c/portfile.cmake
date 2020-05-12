vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO protobuf-c/protobuf-c
    REF 1390409f4ee4e26d0635310995b516eb702c3f9e #1.3.2
    SHA512 5c60883c4ef064c641875bfe7f89bf255a29dd20b5e0be5878cbaec03f2efd1f926c3e40dc0090cb172b8eef227fddafe86051f08edb3e1c26d0bd6aca673e41
    HEAD_REF master
    PATCHES fix-features.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    tools WITH_TOOLS
    test WITH_TEST
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build-cmake
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

# Include files should not be duplicated into the /debug/include directory.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)