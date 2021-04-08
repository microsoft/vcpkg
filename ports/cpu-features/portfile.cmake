vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/cpu_features
    REF b9593c8b395318bb2bc42683a94f962564cc4664 # 0.4.1
    SHA512 8c12b50741e2979a32b69c788934bee0d00811b7662006c8b493e98d5efeada67ed59460be40c234b2d3bafd85671cb1a1d7c1a6ee535a7fc1cc6ac56a754576
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CpuFeatures TARGET_PATH share/CpuFeatures)

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES list_cpu_features)
endif()
vcpkg_clean_executables_in_bin(FILE_NAMES list_cpu_features)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
