set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "qml"           CMAKE_REQUIRE_FIND_PACKAGE_Qt6Quick
    "vulkan"        CMAKE_REQUIRE_FIND_PACKAGE_Vulkan
    "vulkan"        FEATURE_qt3d_vulkan
    "rhi"           FEATURE_qt3d_rhi_renderer
    "render"        FEATURE_qt3d_render
    "input"         FEATURE_qt3d_input
    "logic"         FEATURE_qt3d_logic
    "extras"        FEATURE_qt3d_extras
    "animation"     FEATURE_qt3d_animation
    "assimp"        FEATURE_qt3d_assimp
    "assimp"        FEATURE_qt3d_system_assimp
INVERTED_FEATURES
    "qml"           CMAKE_DISABLE_FIND_PACKAGE_Qt6Quick
    "vulkan"        CMAKE_DISABLE_FIND_PACKAGE_Vulkan
    "assimp"        CMAKE_DISABLE_FIND_PACKAGE_WrapQt3DAssimp
    )

# qt3d-system-assimp reads INPUT_assimp, not the declared INPUT_qt3d_assimp
if("assimp" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_assimp=system)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        #-DINPUT_fbxsdk=no
                        -DFEATURE_qt3d_fbxsdk=OFF # OpenFBX? Probably not!
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                     CONFIGURE_OPTIONS_RELEASE
                        -DCMAKE_TRY_COMPILE_CONFIGURATION=Release
                     CONFIGURE_OPTIONS_DEBUG
                    )
