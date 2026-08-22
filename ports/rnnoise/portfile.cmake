vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xiph/rnnoise
    REF "v${VERSION}"
    SHA512 0f7de78494e0f2421c09871e9328437b64d021fd046c2198b836e84028995b43a56d113fb5ebc0bd76c1cb308a9cc53f67d6de5c1f67281248af492eab534bbc
    HEAD_REF main
)

vcpkg_download_distfile(
    MODEL_PATH
    URLS https://media.xiph.org/rnnoise/models/rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz
    FILENAME rnnoise_data-0a8755f8e2d834eff6a54714ecc7d75f9932e845df35f8b59bc52a7cfe6e8b37.tar.gz
    SHA512 b327d2fc5095be9ed66c5246a86b1a1ce180e9de875c4e5e8778f975560d1f035da40a8686dc1c3fd91c8e709be65d2638eccaa9f866b6f3d85f8d0d16bd2184
)

vcpkg_extract_archive(
    ARCHIVE "${MODEL_PATH}"
    DESTINATION "${SOURCE_PATH}/modeldata"
)
file(COPY "${SOURCE_PATH}/modeldata/src/rnnoise_data.c" DESTINATION "${SOURCE_PATH}/src/")
file(COPY "${SOURCE_PATH}/modeldata/src/rnnoise_data.h" DESTINATION "${SOURCE_PATH}/src/")
file(COPY "${SOURCE_PATH}/modeldata/src/rnnoise_data_little.c" DESTINATION "${SOURCE_PATH}/src/")
file(COPY "${SOURCE_PATH}/modeldata/src/rnnoise_data_little.h" DESTINATION "${SOURCE_PATH}/src/")
file(COPY "${SOURCE_PATH}/modeldata/models/rnnoise10Ga_12.pth" DESTINATION "${SOURCE_PATH}/models/")
file(COPY "${SOURCE_PATH}/modeldata/models/rnnoise10Gb_15.pth" DESTINATION "${SOURCE_PATH}/models/")

vcpkg_make_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTORECONF
)

vcpkg_make_install()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
