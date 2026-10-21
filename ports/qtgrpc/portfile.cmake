set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES protoc-host.patch)
set(TOOL_NAMES qtprotobufgen qtgrpcgen)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Qml
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Qml
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Gui
)
if(NOT "qml" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DFEATURE_protobuf_qtguitypes=OFF)
endif()
# native_grpc ->grpc WrapgRPC
# grp -> qt[network]
# qtprotobufgen -> protobuf WrapProtobuf
qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                        #--trace-expand
                     CONFIGURE_OPTIONS_MAYBE_UNUSED
                         QT_BUILD_EXAMPLES
                         QT_USE_DEFAULT_CMAKE_OPTIMIZATION_FLAGS
                    )
