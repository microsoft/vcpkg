# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vietjtnguyen/argagg
    REF "${VERSION}"
    SHA512 85634bff33236ffcb0aea03a6fa4b3529b6d1faa03f8e030f3c5401fc453bb5e1964f7d0644e4f3fc089ccd7751ea94c466e02b85f7c9701ce21adcc20c0b058
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARGAGG_BUILD_EXAMPLES=OFF
        -DARGAGG_BUILD_TESTS=OFF
        -DARGAGG_BUILD_DOCS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
