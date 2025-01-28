vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/bsa
    REF 4.1.0
    SHA512 c488a4f7cffa59064baafd429cf118a8f8a7b5594a0bd49a0ed468572b37af2e7428a83ad83cc7b13b556744a444cb7b8a4591c7018e49cadb1c5d42ae780f51
    HEAD_REF master
    PATCHES
        DirectXTexUint8Byte.patch
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
