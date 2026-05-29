# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/csv
    REF 13e04e5b31b585855c7d7e7f3c65e47ae863569b
    SHA512 ddcdc7af68a0dabb2b7e15822f5900461b9f424ff5e0ac6cafd2454c2f21ca97785ef09ddb805a92e2452fe14c14167c762a822a8af6c5b86446f67e7f3f71bd
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCSV_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
