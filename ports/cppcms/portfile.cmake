vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO artyom-beilis/cppcms
    REF v${VERSION}
    SHA512 b91da68b3e277cf3814f6772a2580db95d55a9022b165b44f9d2fde0bc13779e9198b45e1ebdbd10189cb192109a61777888ce0670644da1e64a0e1008a827a7
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
        -DCMAKE_CXX_STANDARD=17
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
