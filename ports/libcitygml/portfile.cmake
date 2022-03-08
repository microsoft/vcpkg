vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jklimke/libcitygml
    REF 081993794cdd3264af396a79358100302fef5a83 # 2.4.0
    SHA512 5daf66d418726a31df3f62330515590e7ebc3d6d833742b1f806ae8e52f6ade04ce6f4c2425356a03b748deec319a8b44340afbb7f6d788507bd91504ef277ac
    HEAD_REF master
    PATCHES
        0001_fix_vs2019.patch
        0002_remove_glu_dep.patch
        0003_fix_tools.patch
        0004_fix_pkgbuild.patch
)

if ("osg" IN_LIST FEATURES)
    SET(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_OSGPLUGIN=ON
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_OSGPLUGIN=OFF
    )
endif()

if ("gdal" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_USE_GDAL=ON
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_USE_GDAL=OFF
    )
endif()

if ("tools" IN_LIST FEATURES)
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_TESTS=ON
    )
else()
    list(APPEND ADDITIONAL_OPTIONS
        -DLIBCITYGML_TESTS=OFF
    )
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
        ${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()
vcpkg_fixup_pkgconfig()
#file(READ "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/citygml.pc" PKGCONFIG_FILE)
#string(REGEX REPLACE "-lcitygml" "-lcitygmld" PKGCONFIG_FILE_MODIFIED "${PKGCONFIG_FILE}" )
#file(WRITE "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/citygml.pc" ${PKGCONFIG_FILE_MODIFIED})
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

