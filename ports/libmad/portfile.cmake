if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://codeberg.org/tenacityteam/libmad/archive/${VERSION}.tar.gz"
    FILENAME "tenacityteam-libmad-${VERSION}.tar.gz"
    SHA512 6752c199096f999ed478dea712eb669913eec182eec8a56bf4871e77e6c38798d13146febf646007427f43f86aea8d40b9ec2b72928ac3132066ebddcaa0cfde
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
