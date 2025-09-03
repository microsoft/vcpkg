vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF "v${VERSION}"
    SHA512 30bc2f10cd7c29ae4e8580afcf6626fb14e5ef5046bad1242c2e6b433a374d6eaaa6093cd3682b84392c9dd75ba90d7090b6899b732a5b98e8790173bddd3020
    HEAD_REF master
    PATCHES
        cxx-for-icu.diff
        disable-docs.patch
        disable-xml2-config.diff
        fix_cmakelist.patch
        fix_ios_compilation.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "http"      LIBXML2_WITH_HTTP
        "iconv"     LIBXML2_WITH_ICONV
        "icu"       LIBXML2_WITH_ICU
        "legacy"    LIBXML2_WITH_LEGACY
        "lzma"      LIBXML2_WITH_LZMA
        "tools"     LIBXML2_WITH_PROGRAMS
        "zlib"      LIBXML2_WITH_ZLIB
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBXML2_WITH_TESTS=OFF
        -DLIBXML2_WITH_HTML=ON
        -DLIBXML2_WITH_C14N=ON
        -DLIBXML2_WITH_CATALOG=ON
        -DLIBXML2_WITH_DEBUG=ON
        -DLIBXML2_WITH_ISO8859X=ON
        -DLIBXML2_WITH_MODULES=ON
        -DLIBXML2_WITH_OUTPUT=ON
        -DLIBXML2_WITH_PATTERN=ON
        -DLIBXML2_WITH_PUSH=ON
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_READER=ON
        -DLIBXML2_WITH_REGEXPS=ON
        -DLIBXML2_WITH_SAX1=ON
        -DLIBXML2_WITH_SCHEMAS=ON
        -DLIBXML2_WITH_SCHEMATRON=ON
        -DLIBXML2_WITH_THREADS=ON
        -DLIBXML2_WITH_THREAD_ALLOC=OFF
        -DLIBXML2_WITH_VALID=ON
        -DLIBXML2_WITH_WRITER=ON
        -DLIBXML2_WITH_XINCLUDE=ON
        -DLIBXML2_WITH_XPATH=ON
        -DLIBXML2_WITH_XPTR=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
    OPTIONS_DEBUG
        -DLIBXML2_WITH_PROGRAMS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libxml2-${VERSION}")
vcpkg_fixup_pkgconfig()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xmllint xmlcatalog AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libxml2/libxml/xmlexports.h" "#ifdef LIBXML_STATIC" "#if 1 /* LIBXML_STATIC */")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright")
