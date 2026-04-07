
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/fxdiv
    REF 63058eff77e11aa15bf531df5dd34395ec3017c8
    SHA512 da33eab4d006645f383a1f24fc3e747db3aeb0613219297ec0ae69aa2617f07ba050ebd6a64a8cbde6d25481f176d0ec3b9753a95d1fbcead2136595f3e50e97
    PATCHES
    add-cmake-config.patch
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFXDIV_BUILD_TESTS=OFF
        -DFXDIV_BUILD_BENCHMARKS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
