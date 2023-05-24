vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DCMTK/dcmtk
    REF a137f1aff4e1df3fbefe53ee8b160973c74c96dd # DCMTK-3.6.7
    SHA512 dd41b38ef5d02ac2bf4071e1c27814e03357bc6a51eef59daf47a86d024d7fcbaaa1a71df8600fb8180f8b6537d45d6bf48a00730c1fa9d147778f36ff3e425a
    HEAD_REF master
    PATCHES
        dcmtk.patch
        windows-patch.patch
)

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

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DDCMTK_WITH_DOXYGEN=OFF
        -DDCMTK_FORCE_FPIC_ON_UNIX=ON
        -DDCMTK_OVERWRITE_WIN32_COMPILER_FLAGS=OFF
        -DDCMTK_ENABLE_PRIVATE_TAGS=ON
        -DCMAKE_CXX_STANDARD=17
        -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS=ON
        -DDCMTK_WIDE_CHAR_MAIN_FUNCTION=ON
        -DDCMTK_ENABLE_STL=ON
        -DCMAKE_DEBUG_POSTFIX=d
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
        -DBUILD_APPS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

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
        mkreport
        movescu
        msgserv
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

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DCMTK_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DCM_DICT_DEFAULT_PATH \"${CURRENT_PACKAGES_DIR}/share/dcmtk/dicom.dic:${CURRENT_PACKAGES_DIR}/share/dcmtk/private.dic\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DEFAULT_CONFIGURATION_DIR \"${CURRENT_PACKAGES_DIR}/etc/dcmtk/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DEFAULT_SUPPORT_DATA_DIR \"${CURRENT_PACKAGES_DIR}/share/dcmtk/\"" "")

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
