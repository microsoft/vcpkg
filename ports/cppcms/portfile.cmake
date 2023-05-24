vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF b72b19915794d1af63c9a9e9bea58e20a4ad93d4
    SHA512 e99d34d14fbde22be725ac2c0bec069fb584e45c66767af75efaf454ca61a7a5e57434bf86109f910884c72202b8cf98fe16505e7d3d30d9218abd4d8b27d5df
    PATCHES
        no-tests-and-examples.patch
        fix_narrowing_error.patch
)

vcpkg_find_acquire_program(PYTHON2)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DISABLE_DYNAMIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYTHON=${PYTHON2} # Switch to python3 on the next update
        -DUSE_WINDOWS6_API=ON
        -DDISABLE_SHARED=${DISABLE_DYNAMIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES cppcms_scale cppcms_make_key cppcms_config_find_param AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/MIT.TXT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
