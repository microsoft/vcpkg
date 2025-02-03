vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF b72b19915794d1af63c9a9e9bea58e20a4ad93d4
    SHA512 e99d34d14fbde22be725ac2c0bec069fb584e45c66767af75efaf454ca61a7a5e57434bf86109f910884c72202b8cf98fe16505e7d3d30d9218abd4d8b27d5df
    PATCHES
        dependencies.diff
        dllexport.diff
        no-tests-and-examples.patch
        fix_narrowing_error.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" DISABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" DISABLE_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11
        -DPYTHON=:
        -DUSE_WINDOWS6_API=ON
        -DDISABLE_SHARED=${DISABLE_SHARED}
        -DDISABLE_STATIC=${DISABLE_STATIC}
        -DDISABLE_GCRYPT=ON
        -DDISABLE_ICONV=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
foreach(script IN ITEMS cppcms_tmpl_cc cppcms_run)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${script}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${script}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${script}")
endforeach()
vcpkg_copy_tools(TOOL_NAMES cppcms_scale cppcms_make_key cppcms_config_find_param AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/MIT.TXT" "${SOURCE_PATH}/THIRD_PARTY_SOFTWARE.TXT")
