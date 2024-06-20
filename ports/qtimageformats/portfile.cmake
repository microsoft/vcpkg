set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled) # Only plugins
set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES no_target_promotion_latest.patch)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    #"jasper"              CMAKE_REQUIRE_FIND_PACKAGE_WrapJasper
    #"webp"                CMAKE_REQUIRE_FIND_PACKAGE_WrapWebP
    #"tiff"                CMAKE_REQUIRE_FIND_PACKAGE_TIFF
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
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON # Cf. QTBUG-95052
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
