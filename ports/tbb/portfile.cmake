
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF "v${VERSION}"
    SHA512 7db4a41e3b0e34a559299451f7eef633190e7e4be1819f609f773ac6b7f3d31ff5e45f3cfabd3606e280adb930d47a77a31377e5ef72c85dcb37a354d8b87e55
    HEAD_REF master
    PATCHES
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        hwloc TBB_DISABLE_HWLOC_AUTOMATIC_SEARCH)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DTBB_TEST=OFF
        -DTBB_STRICT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TBB")
vcpkg_copy_pdbs()

if(NOT VCPKG_BUILD_TYPE)
    if(VCPKG_TARGET_ARCHITECTURE MATCHES "^(x86|arm|wasm32)$")
        set(arch_suffix "32")
    endif()
    if(VCPKG_TARGET_IS_WINDOWS)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tbb${arch_suffix}.pc" "-ltbb12" "-ltbb12_debug")
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/tbb${arch_suffix}.pc" "-ltbb" "-ltbb_debug")
    endif()
    unset(arch_suffix)
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    # These are duplicate libraries provided on Windows -- users should use the tbb12 libraries instead
    "${CURRENT_PACKAGES_DIR}/lib/tbb.lib"
    "${CURRENT_PACKAGES_DIR}/debug/lib/tbb_debug.lib"
)

file(READ "${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/tbb/TBBConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${_contents}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
