# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simd-everywhere/simde
    REF "v${VERSION}"
    SHA512 b0667583565ea9e59d18a07c7a3cb46710868c9572663e314278ca2004747e337e34f6b927c9c5d29e161caba8ec0428e5299b6e878e226b9f33597a1584b91d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/simde" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
