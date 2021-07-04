vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    openssl     BUILD_SSL 
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Corvusoft/restbed
    REF 4.7
    SHA512 f8aaa89ae5c862253f9a480fefa8827927e3a6c13c51938bbcd6c28ac4e6d54496ecf51610343e9a3efe3e969314f643a487506c606a65f56125b51ab8478652
    HEAD_REF master
    PATCHES
        use-FindOpenSSL-cmake.patch
        asio-1-18-0-deprecations.patch #https://github.com/Corvusoft/restbed/pull/444/files
        fix-ninja-duplicates.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/Findopenssl.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

#Remove include debug files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
