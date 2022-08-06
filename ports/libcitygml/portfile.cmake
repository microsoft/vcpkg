vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jklimke/libcitygml
    REF 4dacf5d61da59fa7efd91ea6c3c0cf9a48c85bb4 # 2.4.3
    SHA512 765f9d05fba9108cb6f23803824a61ab0bf30b05ae4cf5c8faa87915c03bb3ad5c1fdc03d420aea2dd3708d60040d6e10232a714595ab161f6e1527f3176d2aa
    HEAD_REF master
    PATCHES
        0001_cmake_path.patch
        0002_fix_tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        osg         LIBCITYGML_OSGPLUGIN
        gdal        LIBCITYGML_USE_GDAL
        tools       LIBCITYGML_TESTS
)

if ("osg" IN_LIST FEATURES)
    SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_DYNAMIC=ON
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_DYNAMIC=OFF
    )
endif()

if (VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        list(APPEND ADDITIONAL_OPTIONS
            -DLIBCITYGML_STATIC_CRT=ON
        )
    else()
        list(APPEND ADDITIONAL_OPTIONS
            -DLIBCITYGML_STATIC_CRT=OFF
        )
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME citygml
    CONFIG_PATH lib/cmake/citygml
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES citygmltest
        AUTO_CLEAN
    )
    if ("osg" IN_LIST FEATURES)
        vcpkg_copy_tools(
            TOOL_NAMES citygmlOsgViewer
            AUTO_CLEAN
        )
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

