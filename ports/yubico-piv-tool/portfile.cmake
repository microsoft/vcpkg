vcpkg_download_distfile(ARCHIVE
    URLS "https://developers.yubico.com/yubico-piv-tool/Releases/yubico-piv-tool-${VERSION}.tar.gz"
    FILENAME "yubico-piv-tool-${VERSION}.tar.gz"
    SHA512 2bac8a875c7c5c3d1e5e8ec84fc70b37fc5b08985ef7ef96f6a9eaf5be882eeb9b1dbfb6cc0d6f5c00586f625cefa38c2d34d0e5aef5164be7274162af3554b8
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        patches/fix-build-system.patch
)

# Map vcpkg linkage to upstream's BUILD_STATIC_LIB option
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" YKPIV_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_ONLY_LIB=ON
        -DBUILD_STATIC_LIB=${YKPIV_BUILD_STATIC}
        -DSKIP_TESTS=1
        -DENABLE_HARDWARE_TESTS=OFF
        -DGENERATE_MAN_PAGES=OFF
        -DENABLE_COVERAGE=OFF
        -DENABLE_CERT_COMPRESS=ON
        -DYKPIV_INSTALL_LIB_DIR=lib
        -DYKPIV_INSTALL_INC_DIR=include
        -DYKPIV_INSTALL_BIN_DIR=bin
        -DYKPIV_INSTALL_PKGCONFIG_DIR=lib/pkgconfig
    MAYBE_UNUSED_VARIABLES
        SKIP_TESTS  # Not consumed when BUILD_ONLY_LIB is ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

# Remove duplicate/unnecessary dirs from debug
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Install unofficial CMake config
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-libykpiv-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-libykpiv")

# Install usage instructions
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
