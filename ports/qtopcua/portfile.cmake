set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES fix-build.patch)

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "open62541"      FEATURE_open62541
#    "open62541"      FEATURE_open62541_security # requires vendored open62541
    "ns0idnames"     FEATURE_ns0idnames
    "ns0idgenerator" FEATURE_ns0idgenerator
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    )
if("open62541" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=system)
    vcpkg_find_acquire_program(PYTHON3)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=no)
endif()

set(TOOL_NAMES 
        qopcuaxmldatatypes2cpp
)
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                    )
