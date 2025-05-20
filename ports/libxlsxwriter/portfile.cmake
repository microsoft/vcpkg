vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 f89a5ec32526ecc080037710e328467f2231b0f99be5f3b8336fb3be45f0786761fdcf28db57f27f85ece62e88830d770547fdde38545327299f7d041becbaf5
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
