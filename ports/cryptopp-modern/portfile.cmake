vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cryptopp-modern/cryptopp-modern
    REF "${VERSION}"
    SHA512 d52b866fc26dc127c797fbf02a78b788af1b129a2c10b5492a1ba8a995d2967ca357b7cdc8ad0b5d1e001148f5e10a274523602e54aa84bf724a00aa08e7a3c7
    HEAD_REF main
)

# Disable ASM on Windows except x64 (only x64 has proper MASM support)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
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
