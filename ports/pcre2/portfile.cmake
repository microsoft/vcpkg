vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PCRE2Project/pcre2
    REF "pcre2-${VERSION}"
    SHA512 2c4fd0bcd6c4f606627c17336d583e14d7bd3f5cd5ab0219ded46e7d784a792a8bbd33332fd06772f451041c046e15d1feaa6b48d8f9aa00dcddbc6cdb89be92
    HEAD_REF master
    PATCHES
        pcre2-10.35_fix-uwp.patch
        no-static-suffix.patch
        fix-cmake.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SLJIT_SOURCE_PATH
    REPO zherczeg/sljit
    REF 8481dde366d0346ac5475aa03ae48ee44fa74ca4
    SHA512 99a6ab54ee6b9b3b2e241d2f29eb24217c8385bb3b756411116eaed0d91f008401822406710431ccf17ddf687828b8ab6933230e44144bea03f550c0f5ac9210
    HEAD_REF main
)

file(REMOVE_RECURSE "${SOURCE_PATH}/deps/sljit")
file(MAKE_DIRECTORY "${SOURCE_PATH}/deps")
file(RENAME "${SLJIT_SOURCE_PATH}" "${SOURCE_PATH}/deps/sljit")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" INSTALL_PDB)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" BUILD_STATIC_CRT)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        jit   PCRE2_SUPPORT_JIT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -DPCRE2_STATIC_RUNTIME=${BUILD_STATIC_CRT}
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
        -DINSTALL_MSVC_PDB=${INSTALL_PDB}
    )

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(READ "${CURRENT_PACKAGES_DIR}/include/pcre2.h" PCRE2_H)
if(BUILD_STATIC)
    string(REPLACE "defined(PCRE2_STATIC)" "1" PCRE2_H "${PCRE2_H}")
else()
    string(REPLACE "defined(PCRE2_STATIC)" "0" PCRE2_H "${PCRE2_H}")
endif()
file(WRITE "${CURRENT_PACKAGES_DIR}/include/pcre2.h" "${PCRE2_H}")

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

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
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
