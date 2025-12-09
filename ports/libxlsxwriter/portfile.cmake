vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 5934521b0ef913a304dee282ed6914387fb9f330368eec29fa6dadb320e9d44b87840266399e4685df70f3e63de404a4acc01369fd26930e81e8f62ff6993a9d
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
