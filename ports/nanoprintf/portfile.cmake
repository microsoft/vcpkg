# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO charlesnicholson/nanoprintf
    REF "v${VERSION}"
    SHA512 adcfa75a283d181785dd969f100909f57d1b45c8ccc8325e6d9b5f6b59ce7aabab01c9ff78b91bd93ffa079eb9926200452ffabffff6b297c81b1af5d3586214
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/nanoprintf.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
