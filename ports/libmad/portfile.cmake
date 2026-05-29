if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://codeberg.org/tenacityteam/libmad/releases/download/${VERSION}/libmad-${VERSION}.tar.gz"
    FILENAME "tenacityteam-libmad-${VERSION}.tar.gz"
    SHA512 5b0a826408395e8b6b8a33953401355d6c2f1b33ec5085530b4ac8a538c39ffa903ce2e6845e9dcad73936933078959960b2f3fbba11ae091fda5bc5ee310df5
)

vcpkg_extract_source_archive(SOURCE_PATH ARCHIVE "${ARCHIVE}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        aso ASO
)

set(EXTRA_OPTIONS)

# Avoid architecture-specific assembly when targeting WASM.  The upstream
# CMakeLists incorrectly recognizes the CPU as an Intel/64-bit CPU, therefore
# we have to override these flags:
# https://codeberg.org/tenacityteam/libmad/src/commit/84ba587793d61caadf6d1f6c0d94c3e165874a50/CMakeLists.txt
if(VCPKG_TARGET_IS_EMSCRIPTEN)
    list(APPEND EXTRA_OPTIONS "-DFPM_64BIT=OFF -DFPM_INTEL=OFF -DFPM_DEFAULT=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DEXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "mad" CONFIG_PATH "lib/cmake/mad")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
