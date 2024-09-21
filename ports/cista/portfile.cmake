vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO felixguendling/cista
    REF "v${VERSION}"
    SHA512 581280b3bc2e762614034058653ddf21ef50dc19b8f49ee9a15bd1f5a4578b53f0bc03e55a1a92fe8d43836be2ed4932c8b9f1d8ed608b6d4d8b8d90426e8535
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCISTA_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cista)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
