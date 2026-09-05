vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osmocom/rtl-sdr
    REF v${VERSION}
    SHA512 20a1630df7d4da5d263c5ffd4d83a7c2a6fc674e3838bf02b2b59c1da8d946dafc48790d410ab2fcbc0362c2ac70e5cdcae9391c5f04803bf2cdddafd6f58483
    HEAD_REF master
    PATCHES
        dependencies.diff
        library-linkage.diff
        tools.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        tools   BUILD_TOOLS
)

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        "-DCMAKE_REQUIRE_FIND_PACKAGE_PkgConfig=1"
        "-DCMAKE_DISABLE_FIND_PACKAGE_Git=1"
    OPTIONS_DEBUG
        -DBUILD_TOOLS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/rtlsdr)
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/librtlsdr.pc" " -lrtlsdr" " -lrtlsdr_static")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/librtlsdr.pc" " -lrtlsdr" " -lrtlsdr_static")
    endif()
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES rtl_adsb rtl_biast rtl_eeprom rtl_fm rtl_power rtl_sdr rtl_tcp rtl_test  AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
