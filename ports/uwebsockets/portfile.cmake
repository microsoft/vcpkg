vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF "v${VERSION}"
    SHA512 c560723aed1cdbf176a24afc5a7b07bc6fa462e713b282a466eb4d53e4127948a565750c8eae29b8b7f90f7276f69185a0597bcee2479f17b8852c5a09d2fc58
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/src"  DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include/src" "${CURRENT_PACKAGES_DIR}/include/uwebsockets")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
