vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviSynth/AviSynthPlus
    REF "v${VERSION}"
    SHA512 620ad17a8107996dd518a2bb0ece8468325d2c04fdd40a60ef5f2cb2f4b07f752b77c875ca5c2b18532d9533c36dd784e599541d15b2a48d570882f63bd031cf
    HEAD_REF master
)

vcpkg_download_distfile(GHC_ARCHIVE
    URLS "https://github.com/gulrak/filesystem/archive/3f1c185ab414e764c694b8171d1c4d8c5c437517.zip"
    FILENAME filesystem-3f1c185ab414e764c694b8171d1c4d8c5c437517.zip
    SHA512 e3fe1e41b31f840ebc219fcd795e7be2973b80bb3843d6bb080786ad9e3e7f846a118673cb9e17d76bae66954e64e024a82622fb8cea7818d5d9357de661d3d1
)

file(REMOVE_RECURSE "${SOURCE_PATH}/filesystem")
vcpkg_extract_source_archive(extracted_archive ARCHIVE "${GHC_ARCHIVE}")
file(RENAME "${extracted_archive}" "${SOURCE_PATH}/filesystem")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_PLUGINS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/distrib/gpl.txt")
