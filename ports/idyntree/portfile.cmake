vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO robotology/idyntree
    REF "v${VERSION}"
    SHA512 7a65324d3a9f502b43f4ccc84747e3c26a6bbf4323199e0f5849311b20339800892f4345bfed9d02a5accb1f56b4984a34695bada1fc73b91057c1b09e4e24a6
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "assimp" IDYNTREE_USES_ASSIMP
        "irrlicht" IDYNTREE_USES_IRRLICHT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DIDYNTREE_USES_IPOPT:BOOL=OFF
        -DIDYNTREE_USES_OSQPEIGEN:BOOL=OFF
        -DIDYNTREE_USES_MATLAB:BOOL=OFF
        -DIDYNTREE_USES_PYTHON:BOOL=OFF
        -DIDYNTREE_USES_OCTAVE:BOOL=OFF
        -DIDYNTREE_USES_LUA:BOOL=OFF
        -DIDYNTREE_USES_YARP:BOOL=OFF
        -DIDYNTREE_USES_ICUB_MAIN:BOOL=OFF
        -DIDYNTREE_USES_ALGLIB:BOOL=OFF
        -DIDYNTREE_USES_WORHP:BOOL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME iDynTree
    CONFIG_PATH lib/cmake/iDynTree)
vcpkg_copy_pdbs()

set(TOOL_NAMES_LIST idyntree-model-info)
if ("assimp" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES_LIST idyntree-model-simplify-shapes)
endif()
if ("irrlicht" IN_LIST FEATURES)
    list(APPEND TOOL_NAMES_LIST idyntree-model-view)
endif()
vcpkg_copy_tools(
    TOOL_NAMES ${TOOL_NAMES_LIST}
    AUTO_CLEAN
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
