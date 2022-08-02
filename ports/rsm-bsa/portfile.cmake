vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/bsa
    REF 4.0.3
    SHA512 ec8a2aff1c833d7bffd6345ab989bc57137eee3fb2c5b7509027f068783d42d61bcc4b694b53a7961c1c69ee52834efadef9b3c82e1a739c0c5491af75e8dde7
    HEAD_REF master
)

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "Build ${PORT} requires at least gcc 10.")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xmem BSA_SUPPORT_XMEM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME bsa
    CONFIG_PATH "lib/cmake/bsa"
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
