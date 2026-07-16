vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PCRE2Project/pcre2
    REF "pcre2-${VERSION}"
    SHA512 4deef8ce95711e65fe07624e6b2aace794594adb15e8363a0279a7b947bf5c75a5858fbdc5251d0a28a7ca97ae8bba561aa5f85805d5c07d417d3e7b3b3486a4
    HEAD_REF master
    PATCHES
        pcre2-10.35_fix-uwp.patch
        no-static-suffix.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SLJIT_SOURCE_PATH
    REPO zherczeg/sljit
    REF 45f910b78c6605ebf5b53d3ec7cb00f2312fe417
    SHA512 c05c83cc762f430c01e2aaf876aaac41a70b67ed8b91bc81102ad527c8921c5e75b41bab35bb8237dd5f53fecd7b8f31206865efffce2ea0a1aa9c87079fc643
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/deps/sljit")
file(MAKE_DIRECTORY "${SOURCE_PATH}/deps")
file(RENAME "${SLJIT_SOURCE_PATH}" "${SOURCE_PATH}/deps/sljit")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" INSTALL_MSVC_PDB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" PCRE2_STATIC_RUNTIME)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jit   PCRE2_SUPPORT_JIT
)

if(VCPKG_TARGET_IS_ANDROID)
    list(APPEND FEATURE_OPTIONS -DHAVE_VSCRIPT_GNU=FALSE)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DPCRE2_STATIC_RUNTIME=${PCRE2_STATIC_RUNTIME}
        -DPCRE2_BUILD_PCRE2_8=ON
        -DPCRE2_BUILD_PCRE2_16=ON
        -DPCRE2_BUILD_PCRE2_32=ON
        -DPCRE2_SUPPORT_UNICODE=ON
        -DPCRE2_BUILD_TESTS=OFF
        -DPCRE2_BUILD_PCRE2GREP=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_BZip2=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ZLIB=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Readline=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Editline=ON
        -DINSTALL_MSVC_PDB=${INSTALL_MSVC_PDB}
    MAYBE_UNUSED_VARIABLES
        PCRE2_STATIC_RUNTIME
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

if(BUILD_STATIC_LIBS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pcre2.h" "defined(PCRE2_STATIC)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pcre2.h" "defined(PCRE2_STATIC)" "0")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/man"
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/man"
    "${CURRENT_PACKAGES_DIR}/debug/share")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/pcre2")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}/tools/pcre2/pcre2-config")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/pcre2-config" "${CURRENT_PACKAGES_DIR}" [[$(cd "$(dirname "$0")/../.."; pwd -P)]])
if(NOT VCPKG_BUILD_TYPE)
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/pcre2/debug")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/pcre2-config" "${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config" "${CURRENT_PACKAGES_DIR}/debug" [[$(cd "$(dirname "$0")/../../../debug"; pwd -P)]])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/pcre2/debug/pcre2-config" [[${prefix}/include]] [[${prefix}/../include]])
endif()
vcpkg_clean_executables_in_bin(FILE_NAMES none)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
