vcpkg_download_distfile(ARCHIVE
    URLS "https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/ccfits/v${VERSION}/CCfits-${VERSION}.tar.gz"
    FILENAME "CCfits-${VERSION}.tar.gz"
    SHA512 5cb802f41cf0695d0e49924ee163151ee657b93158246766d04c192518c7bed30383405d87b5fb312f5f44af26d5ede3104fab90d93cc232e950f8ae66050fde
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        dependencies.diff
        dll_exports.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.txt")
