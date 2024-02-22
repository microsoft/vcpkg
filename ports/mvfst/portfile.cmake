vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 1d984ac091537f0ea9f804f75654b9bc58d7ece695ceb65a117f26a43d0cb686432b7e00b36a6bfc3932f2beeb9b4954774177b6055c51830d35a6815f35641c
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
)

# Prefer installed config files
file(REMOVE
    "${SOURCE_PATH}/fizz/cmake/FindGMock.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGflags.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindGlog.cmake"
    "${SOURCE_PATH}/fizz/cmake/FindLibevent.cmake"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
