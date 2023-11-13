set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES fix-build.patch)

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "open62541"      FEATURE_open62541
#    "open62541"      FEATURE_open62541_security # requires vendored open62541
    "uacpp"          FEATURE_uacpp
    "ns0idnames"     FEATURE_ns0idnames
    "ns0idgenerator" FEATURE_ns0idgenerator
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    )
if("open62541" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=system
                                -DHAVE_open62541=true)
    vcpkg_find_acquire_program(PYTHON3)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=no)
endif()

if("uacpp" IN_LIST FEATURES)
    message(WARNING "\nPlease note that you have to install the Unified Automation C++ SDK yourself.\n")
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        "-DPYTHON_EXECUTABLE=${PYTHON3}"
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
