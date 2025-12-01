
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF "v${VERSION}"
    SHA512 d87c67514ca17c9769910194a8fac912e183952ad5c408dbceb48edc8aef13375df3d4c9120a7366206c8ab72699ed953df65c11c261e19d8e9d273c73d073f3
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
