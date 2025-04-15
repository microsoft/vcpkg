
set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

# TBB static library is strongly not recommended
# It can result in thread oversubscription and crash at exit in case TBB is used in multiple shared libraries
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF "v${VERSION}"
    SHA512 c87b84964b2c323f61895a532968dfa6413a774c177cffbf6e798a07e74e8da5d449144875771df0a1b02657eeb2a7ae4d41c6c432dbf7ea50e3d5a9ea9f8cd3
    HEAD_REF master
    PATCHES
        fix-lang.patch # https://github.com/uxlfoundation/oneTBB/pull/1606
        fix-gcc-without-gas.patch # https://github.com/uxlfoundation/oneTBB/pull/1603
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
