vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beltoforion/muparser
    REF 6d65387be8f4ef329829c6d6ace779b26942e075 # v2.3.3-1
    SHA512 cda1133b534b1c77d80b15d50d71f372a423fab2bc7b9204d106589350b3cfc955dbfdcfe8c17890e3cfd747b559f4d3c4f0ea6c9c3c73e6aa159afc82bcc6c0
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_SAMPLES=OFF
        -DENABLE_OPENMP=OFF
        -DENABLE_WIDE_CHAR=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/muparser")
vcpkg_fixup_pkgconfig()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/muParserDef.h" "#if defined(_UNICODE)" "#if 0")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/muParserDLL.h" "#ifndef _UNICODE" "#if 1")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/muParserFixes.h" "#ifndef MUPARSER_STATIC" "#if 0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/muParserFixes.h" "#ifndef MUPARSER_STATIC" "#if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
