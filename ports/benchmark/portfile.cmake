#https://github.com/google/benchmark/issues/661
vcpkg_fail_port_install(ON_TARGET "uwp") 

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/benchmark
    REF 8039b4030795b1c9b8cedb78e3a2a6fb89574b6e #v1.5.1
    SHA512 845eaf24ceea35fae0be89fea72ec27326506b1f3677e74a83c8f82dcb55ad6adc9a3d03f849b7b02f90991cd714152c63f9623a480b4f02464a63b5657471d4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBENCHMARK_ENABLE_TESTING=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/benchmark)

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES pthread)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)