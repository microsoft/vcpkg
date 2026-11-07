vcpkg_download_distfile(ARCHIVE
    URLS "https://calceph.imcce.fr/releases/calceph-${VERSION}.tar.gz"
    FILENAME "calceph-${VERSION}.tar.gz"
    SHA512 3503ebc4540534f45e9588179a41802081b15c8c8f1fc59ba5d17509822f31ab02f855e1940d307592bd365a7951cb7413a760c91f46c4a8e431a34531f9723e
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    	-DENABLE_FORTRAN=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_copy_tools(TOOL_NAMES calceph_inspector calceph_queryposition calceph_queryorientation AUTO_CLEAN)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/README.rst" DESTINATION "${CURRENT_PACKAGES_DIR}/share/calceph" RENAME readme.rst)
vcpkg_install_copyright(
    COMMENT "The CALCEPH library is triple-licensed (CECILL-2.1 OR CECILL-B OR CECILL-C)."
    FILE_LIST
        "${SOURCE_PATH}/COPYING_CECILL_V2.1.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_B.LIB"
        "${SOURCE_PATH}/COPYING_CECILL_C.LIB"
)
