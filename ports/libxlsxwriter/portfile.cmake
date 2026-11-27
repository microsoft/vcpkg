vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jmcnamara/libxlsxwriter
    REF "v${VERSION}"
    SHA512 eebf8c332228f2cb4bef689323fe9006a90d46fdae481efe1011ec27b2ecd1de0c772a6663e7388a8fd61d5e3b399d4865fe8af25d796ae30f9eb85c5157a058
    HEAD_REF main
    PATCHES
        minizip.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/include/third_party/ioapi.h"
    "${SOURCE_PATH}/include/third_party/zip.h"
    "${SOURCE_PATH}/third_party/minizip"
)

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

set(public_third_party_files  # used by include/xlsxwriter/common.h
    "${CURRENT_PACKAGES_DIR}/include/xlsxwriter/third_party/queue.h"
    "${CURRENT_PACKAGES_DIR}/include/xlsxwriter/third_party/tree.h"
)
file(GLOB third_party_files "${CURRENT_PACKAGES_DIR}/include/xlsxwriter/third_party/*")
list(REMOVE_ITEM third_party_files ${public_third_party_files})
file(REMOVE_RECURSE ${third_party_files})

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
