vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libimobiledevice
    REF 6fc41f57fc607df9b07446ca45bdf754225c9bd9 # commits on 2023-07-05
    SHA512 0ceae43eb5c193c173536a20a6efde44b0ff4b5e6029342f59cb6b0dcad2fd629713db922f17b331b5f359a649b5402c18637e636bcdb5eb5c53bec12ff94903
    HEAD_REF master
    PATCHES
        001_fix_msvc.patch
        002_fix_static_build.patch
        003_fix_api.patch
        004_fix_tools_msvc.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_fixup_pkgconfig()
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            idevice_id
            idevicebackup
            idevicebackup2
            idevicebtlogger
            idevicecrashreport
            idevicedate
            idevicedebug
            idevicedebugserverproxy
            idevicedevmodectl
            idevicediagnostics
            ideviceenterrecovery
            ideviceimagemounter
            ideviceinfo
            idevicename
            idevicenotificationproxy
            idevicepair
            ideviceprovision
            idevicescreenshot
            idevicesetlocation
            idevicesyslog
        AUTO_CLEAN
    )
endif()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(unofficial-libplist CONFIG)
find_dependency(unofficial-libimobiledevice-glue CONFIG)
find_dependency(unofficial-libusbmuxd CONFIG)
find_dependency(OpenSSL)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
