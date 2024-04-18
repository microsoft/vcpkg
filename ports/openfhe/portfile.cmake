vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openfheorg/openfhe-development
    REF "v${VERSION}"
    SHA512 34acb2ee7e0ca62652f0333c4db611cbfea3e97cbac1a7092431233110edafe07b7e4066a654aeae0b51ee1b88475bacb8fd89b67a97ce926739fd7eb9ef62a2
    HEAD_REF main
    PATCHES
        no-vendored-deps.patch
        test.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_BENCHMARKS=OFF
        -DGIT_SUBMOD_AUTO=OFF
        -DBUILD_UNITTESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DWITH_OPENMP=OFF
        -DBUILD_SHARED=${BUILD_SHARED}
        -DBUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME OpenFHE CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME OpenFHE CONFIG_PATH lib/OpenFHE)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
