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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DEXAMPLE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "mad" CONFIG_PATH "lib/cmake/mad")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
