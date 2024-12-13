vcpkg_download_distfile(FIX_COMPATIBILITY_PATCH
    URLS https://github.com/GNOME/libxml2/commit/b347a008a745778630a9eb4fbd29694f3c135bfa.diff?full_index=1
    FILENAME Fix-compatibility-in-package-version-file.patch
    SHA512 7f5e5f53444c12924b0fefdf3013fa4dab76fb17f552dd827628739a6e65c9817ae7182e1817cea2317e2fc9b8a200ecce4f8cb5661a2614c0548a5b3e508b66
)

vcpkg_download_distfile(ADD_MISSING_BCRYPT_PATCH
    URLS https://github.com/GNOME/libxml2/commit/fe1ee0f25f43e33a9981fd6fe7b0483a8c8b5e8d.diff?full_index=1
    FILENAME Add-missing-Bcrypt-link.patch
    SHA512 22bc2fe4c365a2c9991508484daa3d884ff91803df48b3847f71b2283e240ef3ce4fdc1d230932d837ff94dc02fc53e76e2e5a1c956ef037caacb13d8f9b3982
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF "v${VERSION}"
    SHA512 dfe0529dd2fbb7dc9e79505b9c6ff7f29979fa4392d534c1b8859fa9934c2e7d4da3429265d718292056809a58080af32b130263625cdeb358123774c27da7c6
    HEAD_REF master
    PATCHES
        disable-docs.patch
        fix_cmakelist.patch
        ${FIX_COMPATIBILITY_PATCH}
        ${ADD_MISSING_BCRYPT_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "ftp" LIBXML2_WITH_FTP
        "http" LIBXML2_WITH_HTTP
        "iconv" LIBXML2_WITH_ICONV
        "legacy" LIBXML2_WITH_LEGACY
        "lzma" LIBXML2_WITH_LZMA
        "zlib" LIBXML2_WITH_ZLIB
        "tools" LIBXML2_WITH_PROGRAMS
        "icu"  LIBXML2_WITH_ICU
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
        -DLIBXML2_WITH_TREE=ON
        -DLIBXML2_WITH_VALID=ON
        -DLIBXML2_WITH_WRITER=ON
        -DLIBXML2_WITH_XINCLUDE=ON
        -DLIBXML2_WITH_XPATH=ON
        -DLIBXML2_WITH_XPTR=ON
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libxml2-${VERSION}")
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES xmllint xmlcatalog AUTO_CLEAN)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(_file "${CURRENT_PACKAGES_DIR}/include/libxml2/libxml/xmlexports.h")
    file(READ "${_file}" _contents)
    string(REPLACE "#ifdef LIBXML_STATIC" "#undef LIBXML_STATIC\n#define LIBXML_STATIC\n#ifdef LIBXML_STATIC" _contents "${_contents}")
    file(WRITE "${_file}" "${_contents}")
endif()

file(COPY "${CURRENT_PACKAGES_DIR}/include/libxml2/" DESTINATION "${CURRENT_PACKAGES_DIR}/include") # TODO: Fix usage in all dependent ports hardcoding the wrong include path.

# Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/xml2Conf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xml2Conf.sh")

file(COPY
    "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake"
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/Copyright")
