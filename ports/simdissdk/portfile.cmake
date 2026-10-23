vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USNavalResearchLaboratory/simdissdk
    HEAD_REF main
    REF "simdissdk-1.25"
    SHA512 af2e03572afcbcc219fc9e98ba0d6e1a1d4e75bb450423d37680f344eaf5cb8b297926c460f3dacd81c8f1d00e326887abfb03fa3894f4dd5a2dd7ccc7395118
    PATCHES
        osgearth-find-private-dependencies.patch
        simqt-link-opengl.patch
        wbp-link-opengl.patch
)

# The entt and osgqopengl features are realized by locking the corresponding
# find_package() calls: with the feature enabled the package is required,
# with the feature disabled find_package() is skipped entirely.
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        entt        VCPKG_LOCK_FIND_PACKAGE_EnTT
        osgqopengl  VCPKG_LOCK_FIND_PACKAGE_osgQOpenGL
        simdata     BUILD_SIMDATA
        simvis      BUILD_SIMVIS
        simutil     BUILD_SIMUTIL
        simqt       BUILD_SIMQT
        wbp         ENABLE_WBP_PLUGIN
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" _SDK_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINSTALL_THIRDPARTY_LIBRARIES=OFF
        -DBUILD_SDK_EXAMPLES=OFF
        -DENABLE_UNIT_TESTING=OFF
        -DENABLE_QTDESIGNER_WIDGETS=OFF
        -DSIMNOTIFY_SHARED=${_SDK_SHARED}
        -DSIMCORE_SHARED=${_SDK_SHARED}
        -DSIMDATA_SHARED=${_SDK_SHARED}
        -DSIMVIS_SHARED=${_SDK_SHARED}
        -DSIMUTIL_SHARED=${_SDK_SHARED}
        -DSIMQT_SHARED=${_SDK_SHARED}
        -DPROJECT_INSTALL_OSGPLUGINS_DIR=plugins
    MAYBE_UNUSED_VARIABLES
        ENABLE_QTDESIGNER_WIDGETS
        VCPKG_LOCK_FIND_PACKAGE_EnTT
)

vcpkg_cmake_install()

# F3 (review): the upstream export header SDK/simCore/Common/Export.h defaults to
# __declspec(dllimport) on Windows when none of the *_LIB_EXPORT_* macros are
# defined, which yields unresolved __imp_ symbols for consumers linking the
# static libraries. Because a vcpkg install is either fully static or fully
# dynamic, encode the linkage directly into the installed (shared) header for
# static builds: force every component export macro to expand to nothing so
# static consumers need no package-specific export macros.
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(_export_h "${CURRENT_PACKAGES_DIR}/include/SDK/simCore/Common/Export.h")
    if(NOT EXISTS "${_export_h}")
        set(_export_h "${CURRENT_PACKAGES_DIR}/include/simCore/Common/Export.h")
    endif()
    if(EXISTS "${_export_h}")
        file(READ "${_export_h}" _export_h_contents)
        set(_static_export_block [==[
#ifndef SIMDIS_SDK_VCPKG_STATIC_EXPORT_FIX
#define SIMDIS_SDK_VCPKG_STATIC_EXPORT_FIX
/* Patched by vcpkg for static linkage: force every component export macro to
   expand to nothing so consumers linking the static libraries do not reference
   __imp_ symbols. See https://github.com/microsoft/vcpkg/pull/54484 review. */
#ifndef simNotify_LIB_EXPORT_STATIC
#define simNotify_LIB_EXPORT_STATIC
#endif
#ifndef simCore_LIB_EXPORT_STATIC
#define simCore_LIB_EXPORT_STATIC
#endif
#ifndef simData_LIB_EXPORT_STATIC
#define simData_LIB_EXPORT_STATIC
#endif
#ifndef simVis_LIB_EXPORT_STATIC
#define simVis_LIB_EXPORT_STATIC
#endif
#ifndef simUtil_LIB_EXPORT_STATIC
#define simUtil_LIB_EXPORT_STATIC
#endif
#ifndef simQt_LIB_EXPORT_STATIC
#define simQt_LIB_EXPORT_STATIC
#endif
#endif
]==])
        file(WRITE "${_export_h}" "${_static_export_block}${_export_h_contents}")
    else()
        message(WARNING
            "simdissdk static export header not found at the expected path; "
            "the F3 static-linkage fix was skipped. Inspect the installed include tree.")
    endif()
endif()

# Each SDK component installs its export set to lib/cmake/<component>. Fix up
# each component into its own share/<component> directory so that
# find_package(<component>) resolves through the vcpkg prefix path
# (same pattern as the antlr4 port).
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simCore
    CONFIG_PATH lib/cmake/simCore
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simNotify
    CONFIG_PATH lib/cmake/simNotify
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMDATA)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME simData
        CONFIG_PATH lib/cmake/simData
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()
if(BUILD_SIMQT)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME simQt
        CONFIG_PATH lib/cmake/simQt
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()
if(BUILD_SIMUTIL)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME simUtil
        CONFIG_PATH lib/cmake/simUtil
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()
if(BUILD_SIMVIS)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME simVis
        CONFIG_PATH lib/cmake/simVis
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

# What is left in lib/cmake are the Import___.cmake helpers for the deprecated
# osgQt integration, which is never active in a vcpkg build: osgQt is not a
# dependency, and simQtConfig.cmake only includes ImportOSGQT.cmake when the
# osgQt target was found.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib/cmake"
    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc/SDKFooter.html")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
