vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.gnome.org/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF b48e77cf4f6fa0792c5f4b639707a2b0675e461b
    SHA512 2d20867961b8d8a0cb0411192146882b976c1276d2e8ecd9a7ee3f1eb287f64e59282736f58c641b66abf63ba45c9421f27e13ec09a0b10814cd56987b18cb5b
    HEAD_REF master
    PATCHES 
        fix_cmakelist.patch
)

if (VCPKG_TARGET_IS_UWP)
    message(WARNING "Feature network couldn't be enabled on UWP, disable http and ftp automatically.")
    set(ENABLE_NETWORK 0)
else()
    set(ENABLE_NETWORK 1)
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    "tools"         LIBXML2_WITH_PROGRAMS
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libxml2)
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

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Copyright" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

#Cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/xml2Conf.sh" "${CURRENT_PACKAGES_DIR}/debug/lib/xml2Conf.sh")