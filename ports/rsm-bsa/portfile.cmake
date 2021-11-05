vcpkg_fail_port_install(ON_TARGET "OSX" "UWP" ON_ARCH "x86")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Ryan-rsm-McKenzie/bsa
    REF 4.0.0
    SHA512 9be077349cea3f4c6f2298c6286fd306f370c560d9e474516dfd7ab8dcd2313032581f86f9b4f5afb5ccd2dbb4e57663e16997253421033e00186167db15576a
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

if (BSA_SUPPORT_XMEM)
    vcpkg_fail_port_install(
        ON_TARGET "LINUX"
        MESSAGE "XMem support is only available for windows"
    )
endif()

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
