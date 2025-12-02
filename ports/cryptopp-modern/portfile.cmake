vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cryptopp-modern/cryptopp-modern
    REF "${VERSION}"
    SHA512 758c4813086bd9126d9985c5eac5f5e2002de5ea87f76427f276b8a9ad9de0b85e879d2ef505ed5a2c0cf85a585d10d70cd86638f96fb47e6ffe51cadd65a01c
    HEAD_REF main
)

# Disable ASM on ARM Windows to fix broken build
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "^arm")
    set(CRYPTOPP_DISABLE_ASM ON)
else()
    set(CRYPTOPP_DISABLE_ASM OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCRYPTOPP_BUILD_SHARED=OFF
        -DCRYPTOPP_BUILD_TESTING=OFF
        -DCRYPTOPP_DISABLE_ASM=${CRYPTOPP_DISABLE_ASM}
        -DCRYPTOPP_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/cryptopp-modern)

# Move pkgconfig files to correct locations
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share/pkgconfig/cryptopp-modern.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/cryptopp-modern.pc")
endif()
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/pkgconfig/cryptopp-modern.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/cryptopp-modern.pc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/pkgconfig")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
