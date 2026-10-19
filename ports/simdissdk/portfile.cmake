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
