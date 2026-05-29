vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviSynth/AviSynthPlus
    REF "v${VERSION}"
    SHA512 63a6c793261690500876edf8bd31011700ab077554533efaf613372edd8cdc44a0e348b6e82723ab88be969764d41d031b58fcfbf993e447ef1a280fe90e3f80
    HEAD_REF master
    PATCHES
        backport_409369a.patch # Fix Ninja + MSVC issue
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
