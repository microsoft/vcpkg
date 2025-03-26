vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RippeR37/libbase
    REF "v${VERSION}"
    SHA512 7a1c77815634b8b07f324bcd6bb4a9b0804edb216bdd3f444265c97efdfc1dadd5fb2cf132987626872170ef6fcff5e16e3e1a79246c6107f91cb3192bf1b679
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBBASE_CODE_COVERAGE=OFF
        -DLIBBASE_BUILD_DOCS=OFF
        -DLIBBASE_CLANG_TIDY=OFF
        -DLIBBASE_BUILD_EXAMPLES=OFF
        -DLIBBASE_BUILD_TESTS=OFF
        -DLIBBASE_BUILD_PERFORMANCE_TESTS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "libbase")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
