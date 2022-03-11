vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jklimke/libcitygml
    REF 32c3fda258c008122da943a7b8b3236657543149 # 2.4.1
    SHA512 04fec6a9a57fc08dfc8b8b9c2a6520cd67405a11df40fcfc77f0dde578a370269a66a1610fdba314d4a417ceafffbe497ec556c44c2ee7c9f5ba02af219dda5e
    HEAD_REF master
    PATCHES
        0001_remove_glu_dep.patch
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
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

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

