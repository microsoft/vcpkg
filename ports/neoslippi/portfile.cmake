vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            neoslippi
    FILENAME        "NeoSlippi-${VERSION}.zip"
    SHA512          a1fdd19c0de2e59d3de778be98216702a9c1de05a87b6d7126a6d1ef96c270624f4890ae8d6199498d91e89d2b8219381cb1bf15d29730a402d5152f05c7ea6c
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
