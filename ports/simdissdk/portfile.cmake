vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO USNavalResearchLaboratory/simdissdk
    HEAD_REF main
    REF "11a9530"
    SHA512 9aa2a3e107939bac4a64bea18103d9cd3cd2dd5ac4cfe1699ba0a5b89b4672a00bc8884ea67cb448059762b12ff34f3793d843634ea39fe4810e9e0af08cd69c
    PATCHES
)

# Moving up from vcpkg/ports/simdissdk/ to the project root
#get_filename_component(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        simdata     BUILD_SIMDATA
        simvis      BUILD_SIMVIS
        simutil     BUILD_SIMUTIL
        simqt       BUILD_SIMQT
        wbp         ENABLE_WBP_PLUGIN
)

# If the 'entt' feature was NOT enabled, we tell CMake to hide EnTT
if("entt" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_EnTT=OFF")
else()
    list(APPEND FEATURE_OPTIONS "-DCMAKE_DISABLE_FIND_PACKAGE_EnTT=ON")
endif()

# If the 'osg-qt' feature was NOT enabled, we tell CMake to hide it
if("osg-qt" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt5=OFF"
        "-DCMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt6=OFF"
    )
else()
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt5=ON"
        "-DCMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt6=ON"
    )
endif()

set(_SDK_SHARED ON)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(_SDK_SHARED OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINSTALL_THIRDPARTY_LIBRARIES=OFF
        -DBUILD_SDK_EXAMPLES=OFF
        -DENABLE_QTDESIGNER_WIDGETS=OFF
        -DSIMNOTIFY_SHARED=${_SDK_SHARED}
        -DSIMCORE_SHARED=${_SDK_SHARED}
        -DSIMDATA_SHARED=${_SDK_SHARED}
        -DSIMVIS_SHARED=${_SDK_SHARED}
        -DSIMUTIL_SHARED=${_SDK_SHARED}
        -DSIMQT_SHARED=${_SDK_SHARED}
    OPTIONS_DEBUG
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt5
        CMAKE_DISABLE_FIND_PACKAGE_osgQOpenGL-qt6
        CMAKE_DISABLE_FIND_PACKAGE_EnTT
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME simCore 
    CONFIG_PATH lib/cmake/simCore 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
if(BUILD_SIMDATA)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simData 
    CONFIG_PATH lib/cmake/simData 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
endif()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME simNotify 
    CONFIG_PATH lib/cmake/simNotify 
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
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

vcpkg_cmake_config_fixup(
    PACKAGE_NAME simdissdk 
    CONFIG_PATH lib/cmake
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/doc")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc/SDKFooter.html")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/README.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/INSTALL.md")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/LICENSE.txt")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/README.md")
