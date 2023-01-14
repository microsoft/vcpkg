vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/string-view-lite
    REF v1.6.0
    SHA512 a21c4c956360b76cf6f530ae7c26d97777d4c37164e6fc0da0dc931d41378aa020a235e40d7f8e8160c1b9dab552c6d7bf3aa7697e9048effef2b3cee8573553
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTRING_VIEW_LITE_OPT_BUILD_TESTS=OFF
        -DSTRING_VIEW_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright
)
