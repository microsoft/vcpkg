include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Corvusoft/restbed
    REF 0f8af8d8ed183a88e208adeb22da0080d5d74d1e
    SHA512 f0175a10c88f1ad4f16c8e4cff7ceea7b80c56b0724b59791c23e91f1ecf146dfdbda9e9238d31a35f21d8cdcc413b586cc633725dd0ba87de6b599a7087916f
    HEAD_REF master
    PATCHES cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SSL=OFF
        -DDISABLE_TESTS=ON
)

vcpkg_install_cmake()

#Remove include debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/restbed/copyright COPYONLY)
