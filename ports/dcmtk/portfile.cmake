vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DCMTK/dcmtk
    REF 6cb30bd7fb42190e0188afbd8cb961c62a6fb9c9 # DCMTK-3.6.6
    SHA512 3fbd524bc0b9dced2cdddca850c88d8785ca5f333c5f1598ffbffb8e5c33d11eebdce9ed935245048ac45a7ccd7bd9e4ca79eaacf752cba64a5534b76e5efcdb
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
        -DDCMTK_ENABLE_BUILTIN_DICTIONARY=ON
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

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/dcmtk" RENAME copyright)
