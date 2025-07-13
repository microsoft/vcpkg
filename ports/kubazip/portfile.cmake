vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SamuelMarks/zip
    REF 30e8028fb454d70c392a91fc668dc47548d38417
    SHA512 35a967dc4470f25e2502e4f248dd5cbea605f016aceb94feb4a3635983a00c0fbd4086262ae90dfde5000aa69520ff11aa16f4955c64097e84877da11f094f2c
    HEAD_REF c89-vcpkg
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_DISABLE_TESTING=ON"
        "-DCMAKE_PROJECT_NAME=${PORT}"
)

vcpkg_cmake_install()
#vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/zip" PACKAGE_NAME "zip-kuba--")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
