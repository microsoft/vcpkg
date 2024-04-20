vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 753faf1aa2d10a99242f3a06882db90eebf13d923bc4cec94401e02b203d39b3943b0e6076ddff3e522ca825243e4dcce0143f55ce7f839d0f57b4b42f44caf0
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
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
