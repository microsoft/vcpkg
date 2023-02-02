vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beltoforion/muparser
    REF 59e0ce1e0d35d42713af67788f19797945d81364 # v2.3.4
    SHA512 4d0261b9c155b2697ce7222d87ff19be781919e93154bf69455ce36432f66abe2a1ea80a59f7526990f7859f78259014ef56702aa5c7db2ac8c28c8e9491e1f5 
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
