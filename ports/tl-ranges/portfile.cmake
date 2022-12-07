vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO TartanLlama/ranges
    REF dcf57390a060c8d02baec95bde2ea899dd21c4d7
    SHA512 d259306112eed7c6445a019b5773ef4b6ef466a26bbd4aa805b36cfc40161d4b32b15b4ce606e038dc20022c9639ea1943c10d125f70f34e4a5f52b4edc3bb6b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRANGES_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)