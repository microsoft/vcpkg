vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KarypisLab/ParMETIS
    REF 44fadbf58c71a74b39abb110a7691355d2a760ca
    SHA512 d07e2ccb358948b728be3d282841ad42a8358908a4f1ab3342d4c3016e71a06c1b5966640a06e713f4c773365d7dba4f0c68795d615802f3af07194c0778f362
    PATCHES
        build-fixes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSHARED=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" [=[
parmetis provides CMake targets:
    find_package(parmetis CONFIG REQUIRED)
    target_link_libraries(main PRIVATE parmetis)
]=])
