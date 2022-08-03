vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DCMTK/dcmtk
    REF a137f1aff4e1df3fbefe53ee8b160973c74c96dd # DCMTK-3.6.7
    SHA512 dd41b38ef5d02ac2bf4071e1c27814e03357bc6a51eef59daf47a86d024d7fcbaaa1a71df8600fb8180f8b6537d45d6bf48a00730c1fa9d147778f36ff3e425a
    HEAD_REF master
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/dcmtk.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDCMTK_WITH_DOXYGEN=OFF
        -DDCMTK_WITH_ZLIB=OFF
        -DDCMTK_WITH_OPENSSL=OFF
        -DDCMTK_WITH_PNG=OFF
        -DDCMTK_WITH_TIFF=OFF
        -DDCMTK_WITH_XML=OFF
        -DDCMTK_WITH_ICONV=OFF
        -DDCMTK_FORCE_FPIC_ON_UNIX=ON
        -DDCMTK_OVERWRITE_WIN32_COMPILER_FLAGS=OFF
        -DDCMTK_ENABLE_PRIVATE_TAGS=ON
        -DBUILD_APPS=OFF
        -DDCMTK_ENABLE_CXX11=ON
        -DDCMTK_WIDE_CHAR_FILE_IO_FUNCTIONS=ON
        -DDCMTK_WIDE_CHAR_MAIN_FUNCTION=ON
        -DCMAKE_DEBUG_POSTFIX=d
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
        -DINSTALL_OTHER=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DCMTK_PREFIX \"${CURRENT_PACKAGES_DIR}\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DCM_DICT_DEFAULT_PATH \"${CURRENT_PACKAGES_DIR}/share/dcmtk/dicom.dic:${CURRENT_PACKAGES_DIR}/share/dcmtk/private.dic\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DEFAULT_CONFIGURATION_DIR \"${CURRENT_PACKAGES_DIR}/etc/dcmtk/\"" "")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/dcmtk/config/osconfig.h" "#define DEFAULT_SUPPORT_DATA_DIR \"${CURRENT_PACKAGES_DIR}/share/dcmtk/\"" "")

vcpkg_fixup_pkgconfig()
# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dcmtk" RENAME copyright)
