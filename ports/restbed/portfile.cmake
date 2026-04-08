vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl     BUILD_SSL
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Corvusoft/restbed
    REF "${VERSION}"
    SHA512 f012d6574cc6eccccde71c44009a440f05fd72a2db74acb4eff10d0b96156e83a0643a83dccd52a8a0b3c48e88eb5451e939775a4655e0cb7de51aa68df5cab8
    HEAD_REF master
    PATCHES
        fix-cmake.patch
)

file(REMOVE "${SOURCE_PATH}/cmake/Findopenssl.cmake")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RESTBED_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" RESTBED_BUILD_DYNAMIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_TESTS=OFF
        -DBUILD_STATIC_LIBRARY=${RESTBED_BUILD_STATIC}
        -DBUILD_SHARED_LIBRARY=${RESTBED_BUILD_DYNAMIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-restbed)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
