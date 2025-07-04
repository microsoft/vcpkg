vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO f3d-app/f3d
    REF v${VERSION}
    SHA512 ffaacb7fdf39ad35ffd5ba9313d7d2c915085656f17a27f4d920b910747123b10282a916200e038309c121652a2dc6b7724a9ca6570d89e6aeeedf25617b5f80
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        # optional modules
        exr     F3D_MODULE_EXR
        # optional plugins
        alembic F3D_PLUGIN_BUILD_ALEMBIC
        assimp  F3D_PLUGIN_BUILD_ASSIMP
        draco   F3D_PLUGIN_BUILD_DRACO
        occt    F3D_PLUGIN_BUILD_OCCT
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_build()

# Install components
foreach(build_type IN ITEMS debug release)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR "${VCPKG_BUILD_TYPE}" STREQUAL "${build_type}")
        if("${build_type}" STREQUAL "debug")
            set(short_build_type "dbg")
            set(config "Debug")
        else()
            set(short_build_type "rel")
            set(config "Release")
        endif()
        foreach(install_component IN ITEMS application library sdk)
            vcpkg_execute_build_process(
                COMMAND "${CMAKE_COMMAND}" --install . --config "${config}" --component ${install_component}
                WORKING_DIRECTORY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-${short_build_type}"
                LOGNAME "install-${install_component}-${TARGET_TRIPLET}-${short_build_type}"
            )
        endforeach()
    endif()
endforeach()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/f3d)

# f3d_PREFIX_DIR is used as a workaround for a bug introduced in CMake 3.29
# https://github.com/f3d-app/f3d/pull/1377
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/f3d/library-config.cmake" "f3d_PREFIX_DIR" "PACKAGE_PREFIX_DIR")

vcpkg_copy_pdbs()

vcpkg_copy_tools(TOOL_NAMES f3d AUTO_CLEAN)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
