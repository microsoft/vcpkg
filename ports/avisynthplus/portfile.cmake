vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AviSynth/AviSynthPlus
    REF v3.7.0
    SHA512 0f2d5344c4472b810667b99d9e99a2ec8135923f4185dbd7e29ca65e696ce13500ea20ef09c995486573314149a671e1256a4dd0696c4ace8d3ec3716ffdcfc7
    HEAD_REF master
)

vcpkg_download_distfile(GHC_ARCHIVE
    URLS "https://github.com/gulrak/filesystem/archive/3f1c185ab414e764c694b8171d1c4d8c5c437517.zip"
    FILENAME filesystem-3f1c185ab414e764c694b8171d1c4d8c5c437517.zip
    SHA512 e3fe1e41b31f840ebc219fcd795e7be2973b80bb3843d6bb080786ad9e3e7f846a118673cb9e17d76bae66954e64e024a82622fb8cea7818d5d9357de661d3d1
)

file(REMOVE_RECURSE ${SOURCE_PATH}/filesystem)
vcpkg_extract_source_archive(extracted_archive ARCHIVE "${GHC_ARCHIVE}")
file(RENAME "${extracted_archive}" "${SOURCE_PATH}/filesystem")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_PLUGINS=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/distrib/gpl.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
