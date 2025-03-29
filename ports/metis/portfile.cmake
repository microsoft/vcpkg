vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("i64" IN_LIST FEATURES)
    set(IDXWIDTH 64)
else()
    set(IDXWIDTH 32)
endif()

if("fp64" IN_LIST FEATURES)
    set(REALWIDTH 64)
else()
    set(REALWIDTH 32)
endif()

configure_file(
    "${CURRENT_PORT_DIR}/build-fixes.patch"
    "${CURRENT_BUILDTREES_DIR}/build-fixes-dynamic.patch"
    @ONLY
)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/METIS
    REF 94c03a6e2d1860128c2d0675cbbb86ad4f261256
    SHA512 9f24329fa0f0856d0b5d10a489574d857bc4538d9639055fc895363cf70aa37342eaf7bc08819500ff6d5b98a4aa99f4241880622b540d4c484ca19e693d3480
    PATCHES
        "${CURRENT_BUILDTREES_DIR}/build-fixes-dynamic.patch"
    )

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [=[
metis provides CMake targets:
    find_package(metis CONFIG REQUIRED)
    target_link_libraries(main PRIVATE metis)
]=])
