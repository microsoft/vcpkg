vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 a961a6d8094cc9f9996c9cf6c143e0382422eb4b63ec68d4ee1cce76afef562656855ed08c630974b67d33a4af9706df602c4ababad0767466b43a3e0563f2cf
    HEAD_REF main
)
file(REMOVE_RECURSE "${SOURCE_PATH}/third_party/minizip")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "dtoa"        USE_DTOA_LIBRARY
    "openssl-md5" USE_OPENSSL_MD5
    "mem-file"    USE_MEM_FILE
)

set(USE_WINDOWSSTORE OFF)
if (VCPKG_TARGET_IS_UWP)
    set(USE_WINDOWSSTORE ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUSE_SYSTEM_MINIZIP=1
        -DWINDOWSSTORE=${USE_WINDOWSSTORE}
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
