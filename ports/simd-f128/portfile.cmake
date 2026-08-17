vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiw302/simd-f128
    REF v1.6.2
    SHA512 9f58ee84aefa763ade97632a3d4e337c87944159360c8d9dca37e0e7cf1cdc2e2bab09777ac7ff1029f1687f13f4162ff44c4e129ee752e646793a37290b0b4a
    HEAD_REF master
)

# Disable building tests during vcpkg install
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "add_subdirectory(tests)" "")
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "enable_testing()" "")

set(VCPKG_BUILD_TYPE release) # Header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSIMD_F128_BUILD_EXAMPLES=OFF
        -DSIMD_F128_BUILD_BENCHMARKS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME simd_f128 CONFIG_PATH lib/cmake/simd_f128)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
