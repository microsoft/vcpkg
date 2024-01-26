if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
    ARCHIVE
    URLS "https://codeberg.org/tenacityteam/libmad/archive/${VERSION}.tar.gz"
    FILENAME "tenacityteam-libmad-${VERSION}.tar.gz"
    SHA512 e56b84e112e3a95cd4fde7be1ce94c4a277275da3cc69ca051113162a84158ac9a1fe9c3f2de186202de5eca5c112aacb87533206288a084cf5ba048e6d95c22
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
