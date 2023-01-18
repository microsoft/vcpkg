vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(VCPKG_POLICY_MISMATCHED_NUMBER_OF_BINARIES enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/oneTBB
    REF "v${VERSION}"
    SHA512 d314e3d88b85c96607a9eda15e3d808bf361eb562a534c59101929236e90c187883e7718e5435b5e7f01f4ee652c9765af95f5f173368b83997e4666b7403a49
    HEAD_REF onetbb_2021
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTBB_TEST=OFF
        -DTBB_STRICT=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/TBB")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

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

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
