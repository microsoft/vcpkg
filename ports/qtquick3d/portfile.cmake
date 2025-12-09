set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
set(${PORT}_PATCHES
    0001-devendor-meshoptimizer.patch
    android-openxr-vulkan.diff
)

include("${SCRIPT_PATH}/qt_install_submodule.cmake")

# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "assimp"  FEATURE_quick3d_assimp
    #"assimp"  CMAKE_REQUIRE_FIND_PACKAGE_WrapQuick3DAssimp
    "openxr"  FEATURE_quick3dxr_openxr
INVERTED_FEATURES
    "assimp"  CMAKE_DISABLE_FIND_PACKAGE_WrapQuick3DAssimp
    )

if("assimp" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_quick3d_assimp=system -DTEST_quick3d_assimp=ON)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_quick3d_assimp=no)
endif()

set(TOOL_NAMES balsam balsamui meshdebug shadergen instancer materialeditor shapegen)

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     TOOL_NAMES ${TOOL_NAMES}
                     CONFIGURE_OPTIONS
                        ${FEATURE_OPTIONS}
                        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
