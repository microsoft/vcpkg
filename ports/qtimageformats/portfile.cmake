set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Only plugins
set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES #webp.patch
    )

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
    "jasper"              CMAKE_DISABLE_FIND_PACKAGE_WrapJasper
    "webp"                CMAKE_DISABLE_FIND_PACKAGE_WrapWebP
    "tiff"                CMAKE_DISABLE_FIND_PACKAGE_TIFF
     )

if("jasper" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_jasper=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_jasper=no)
endif()
if("webp" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_webp=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_webp=no)
endif()
if("tiff" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_tiff=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_tiff=no)
endif()
list(APPEND FEATURE_OPTIONS -DINPUT_mng=no) # marked as FIXME

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     #TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        #--trace
                        ${FEATURE_OPTIONS}
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )

if("jasper" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT QT_UPDATE_VERSION)
    file(INSTALL "${SOURCE_PATH}/cmake/FindWrapJasper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/Qt6")
endif()
if("webp" IN_LIST FEATURES AND VCPKG_LIBRARY_LINKAGE STREQUAL "static" AND NOT QT_UPDATE_VERSION)
    file(INSTALL "${SOURCE_PATH}/cmake/FindWrapWebP.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/Qt6")
endif()
