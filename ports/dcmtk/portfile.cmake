vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DCMTK/dcmtk
    REF 59f75a8b50e50ae1bb1ff12098040c6327500740 # DCMTK-3.6.8
    SHA512 2719e2163d57339a81f079c8c28d4e9e3ee6b1b85bc3db5b94a2279e3dd9881ab619d432d64984e6371569866d7aa4f01bf8b41841b773bcd60bbb8ad2118cac
    HEAD_REF master
    PATCHES
        dcmtk.patch
        dependencies.diff
        dictionary_paths.patch
        disable-test-setup.diff
        pkgconfig-lib-order.diff
        msvc.diff
)
file(REMOVE
    "${SOURCE_PATH}/CMake/FindICONV.cmake"
    "${SOURCE_PATH}/CMake/FindICU.cmake"
    "${SOURCE_PATH}/CMake/FindJPEG.cmake"
)

# Prefix all exported API symbols of vendored libjpeg with "dcmtk_"
file(GLOB src_files "${SOURCE_PATH}/dcmjpeg/libijg*/*.c" "${SOURCE_PATH}/dcmjpeg/libijg*/*.h")
foreach(file_path ${src_files})
    file(READ "${file_path}" file_string)
    string(REGEX REPLACE "(#define[ \t\r\n]+[A-Za-z0-9_]*[ \t\r\n]+)(j[a-z]+[0-9]+_)" "\\1dcmtk_\\2" file_string "${file_string}")
    file(WRITE "${file_path}" "${file_string}")
endforeach()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
if(VCPKG_DETECTED_CMAKE_CROSSCOMPILING)
    message(STATUS [[
Cross-compiling DCMTK needs input from executing test programs in the target
environment. You may need to provide a suitable emulator setup, and you can set
values directly with `VCPKG_CMAKE_CONFIGURE_OPTIONS` in a custom triplet file.
For more information see
https://support.dcmtk.org/redmine/projects/dcmtk/wiki/Cross_Compiling
]])
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "iconv"   DCMTK_WITH_ICONV
        "icu"     DCMTK_WITH_ICU
        "openssl" DCMTK_WITH_OPENSSL
        "png"     DCMTK_WITH_PNG
        "tiff"    DCMTK_WITH_TIFF
        "xml2"    DCMTK_WITH_XML
        "zlib"    DCMTK_WITH_ZLIB
        "tools"   BUILD_APPS
)

if("external-dict" IN_LIST FEATURES)
    set(DCMTK_DEFAULT_DICT "external")
    set(DCMTK_ENABLE_BUILTIN_OFICONV_DATA OFF)
else()
    set(DCMTK_DEFAULT_DICT "builtin")
    set(DCMTK_ENABLE_BUILTIN_OFICONV_DATA ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_CXX_STANDARD=17
        -DCMAKE_INSTALL_DOCDIR=share/${PORT}/doc
        -DDCMTK_DEFAULT_DICT=${DCMTK_DEFAULT_DICT}
        -DCMAKE_DISABLE_FIND_PACKAGE_BISON=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_FLEX=ON
        -DDCMTK_ENABLE_BUILTIN_OFICONV_DATA=${DCMTK_ENABLE_BUILTIN_OFICONV_DATA}
        -DDCMTK_ENABLE_PRIVATE_TAGS=ON
        -DDCMTK_ENABLE_STL=ON
        -DDCMTK_OVERWRITE_WIN32_COMPILER_FLAGS=OFF
        -DDCMTK_USE_FIND_PACKAGE=ON
        -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS=ON
        -DDCMTK_WIDE_CHAR_MAIN_FUNCTION=ON
        -DDCMTK_WITH_OPENJPEG=OFF
        -DDCMTK_WITH_DOXYGEN=OFF
        -DDCMTK_WITH_SNDFILE=OFF
        -DDCMTK_WITH_WRAP=OFF
    OPTIONS_DEBUG
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

if ("tools" IN_LIST FEATURES)
    set(_tools
        cda2dcm
        dcm2json
        dcm2pdf
        dcm2pnm
        dcm2xml
        dcmcjpeg
        dcmcjpls
        dcmconv
        dcmcrle
        dcmdata_tests
        dcmdjpeg
        dcmdjpls
        dcmdrle
        dcmdspfn
        dcmdump
        dcmect_tests
        dcmfg_tests
        dcmftest
        dcmgpdir
        dcmicmp
        dcmiod_tests
        dcmj2pnm
        dcml2pnm
        dcmmkcrv
        dcmmkdir
        dcmmklut
        dcmnet_tests
        dcmodify
        dcmp2pgm
        dcmprscp
        dcmprscu
        dcmpschk
        dcmpsmk
        dcmpsprt
        dcmpsrcv
        dcmpssnd
        dcmqridx
        dcmqrscp
        dcmqrti
        dcmquant
        dcmrecv
        dcmrt_tests
        dcmscale
        dcmseg_tests
        dcmsend
        dcmsign
        dcmsr_tests
        dcmtls_tests
        dcod2lum
        dconvlum
        drtdump
        drttest
        dsr2html
        dsr2xml
        dsrdump
        dump2dcm
        echoscu
        findscu
        getscu
        img2dcm
        mkcsmapper
        mkesdb
        mkreport
        movescu
        msgserv
        oficonv_tests
        ofstd_tests
        pdf2dcm
        stl2dcm
        storescp
        storescu
        termscu
        wlmscpfs
        wltest
        xml2dcm
        xml2dsr
    )
    vcpkg_copy_tools(TOOL_NAMES ${_tools} AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# no absolute paths
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h"
    "#define (DCMTK_PREFIX|DCM_DICT_DEFAULT_PATH|DEFAULT_CONFIGURATION_DIR|DEFAULT_SUPPORT_DATA_DIR) \"[^\"]*\""
    "#define \\1 \"\" /* redacted by vcpkg */"
    REGEX
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/share/${PORT}/doc-${VERSION}/COPYRIGHT" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
