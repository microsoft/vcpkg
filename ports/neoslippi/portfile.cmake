vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            neoslippi
    FILENAME        "NeoSlippi-${VERSION}.zip"
    SHA512          670f474cef02cc1367eb5d705f21010f0211026e26038d0fd5b22921fd8a55cdc065e01ebd2210ead6e13d0d5998e90de862d064f8a5eebe536a110ce5fdcda8
    NO_REMOVE_ONE_LEVEL
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTING=False
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/NeoSlippi)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
