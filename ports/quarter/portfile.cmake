vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO coin3d/quarter
        REF "v${VERSION}"
        SHA512 14c382d25e47b54d6ff747830131b0646dba398325ec1c748e543af2b2e1d8f690a34d2cdb18159dbc930dde0b9c8749bf437d8eb02d68b21bc597bb13796ea6
        HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    set(QUARTER_BUILD_SHARED_LIBS OFF)
else()
    set(QUARTER_BUILD_SHARED_LIBS ON)
endif()

if ("qt5" IN_LIST FEATURES)
    set(QUARTER_USE_QT5 ON)
    set(QUARTER_USE_QT6 OFF)
else()
    set(QUARTER_USE_QT6 ON)
    set(QUARTER_USE_QT5 OFF)
endif()

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        -DQUARTER_BUILD_SHARED_LIBS=${QUARTER_BUILD_SHARED_LIBS}
        -DQUARTER_USE_QT6=${QUARTER_USE_QT6}
        -DQUARTER_USE_QT5=${QUARTER_USE_QT5}
        -DQUARTER_BUILD_PLUGIN=OFF
        -DQUARTER_BUILD_EXAMPLES=OFF
        -DQUARTER_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Quarter-${VERSION})
# Qt6 pkg-config files not installed https://github.com/microsoft/vcpkg/issues/25988
# vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")