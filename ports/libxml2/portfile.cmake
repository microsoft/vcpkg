vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF 7846b0a677f8d3ce72486125fa281e92ac9970e8
    SHA512 3b960e410cf812a94938cd31c317f9a8d4b2d5b3e148efb108f6dad86ce8c9553c0fe3b32dd68d15e3d5ada9db07b39f9e0b13906edf6ed1bb1cec4f137bca71
    HEAD_REF master
    PATCHES 
        disable-docs.patch
        fix_cmakelist.patch
        fix-uwp.patch
)

if (VCPKG_TARGET_IS_UWP)
    message(WARNING "Feature network couldn't be enabled on UWP, disable http and ftp automatically.")
    set(ENABLE_NETWORK 0)
else()
    set(ENABLE_NETWORK 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools"     LIBXML2_WITH_PROGRAMS
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBXML2_WITH_TESTS=OFF
        -DLIBXML2_WITH_HTTP=${ENABLE_NETWORK}
        -DLIBXML2_WITH_FTP=${ENABLE_NETWORK}
        -DLIBXML2_WITH_HTML=ON
        -DLIBXML2_WITH_C14N=ON
        -DLIBXML2_WITH_CATALOG=ON
        -DLIBXML2_WITH_DEBUG=ON 
        -DLIBXML2_WITH_DOCB=ON
        -DLIBXML2_WITH_ICONV=ON
        -DLIBXML2_WITH_ISO8859X=ON 
        -DLIBXML2_WITH_ZLIB=ON
        -DLIBXML2_WITH_ICU=OFF # Culprit of linkage issues? Solving this is probably another PR
        -DLIBXML2_WITH_LZMA=ON
        -DLIBXML2_WITH_LEGACY=ON
        -DLIBXML2_WITH_MEM_DEBUG=OFF
        -DLIBXML2_WITH_MODULES=ON
        -DLIBXML2_WITH_OUTPUT=ON
        -DLIBXML2_WITH_PATTERN=ON
        -DLIBXML2_WITH_PUSH=ON
        -DLIBXML2_WITH_PYTHON=OFF
        -DLIBXML2_WITH_READER=ON
        -DLIBXML2_WITH_REGEXPS=ON
        -DLIBXML2_WITH_RUN_DEBUG=OFF
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libxml2)
vcpkg_fixup_pkgconfig()

vcpkg_copy_pdbs()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

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

#Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/xml2Conf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xml2Conf.sh")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
