# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 1148796bcc0fac973ff613b9868426d6948087f7319c88b723f22be659c0f5d5add95b1e256a0d7a84671129a981d1aed9c28dd4aeb44ede5082bd07b0c2b8e7
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
