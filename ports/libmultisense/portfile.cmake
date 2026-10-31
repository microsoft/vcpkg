vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 3f1278a2996517a6ca3c1baed765499365ab1bfd7a15e229e3d5babc7ee41c99b804a69d9e1f9ee9f3e075e01fd9624c04e98e3fad2f7b6b10c8986bd2bbe5a3
    HEAD_REF master
    PATCHES
        0000-disable-error-on-warning.patch
)

vcpkg_check_features(
        OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            json-serialization BUILD_JSON_SERIALIZATION
            json-serialization CMAKE_REQUIRE_FIND_PACKAGE_nlohmann_json
            opencv BUILD_OPENCV
            utilities MULTISENSE_BUILD_UTILITIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_LEGACY_API=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "MultiSenseWire"
    CONFIG_PATH "lib/cmake/MultiSenseWire"
    DO_NOT_DELETE_PARENT_CONFIG_PATH
)
vcpkg_cmake_config_fixup(
    PACKAGE_NAME "MultiSense"
    CONFIG_PATH "lib/cmake/MultiSense"
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# LibMultiSense installs additional CMake helper modules alongside `MultiSenseConfig.cmake`.
# `vcpkg_cmake_config_fixup()` only removes debug-side `*Config`/`*Targets` files, which leaves
# `${CURRENT_PACKAGES_DIR}/debug/share/MultiSense` populated and triggers a post-build policy error.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if ("utilities" IN_LIST FEATURES)
    set(_tool_names
        ChangeIpUtility
        ImageCalUtility
        MultiChannelUtility
        PointCloudUtility
        PtpUtility
        RectifiedFocalLengthUtility
        SaveImageUtility
        VersionInfoUtility
    )
    if ("json-serialization" IN_LIST FEATURES)
        list(APPEND _tool_names DeviceInfoUtility)
    endif ()
    if ("opencv" IN_LIST FEATURES)
        list(APPEND _tool_names FeatureDetectorUtility)
    endif ()
    vcpkg_copy_tools(
        TOOL_NAMES ${_tool_names}
        AUTO_CLEAN
    )

    # Remove the bin directory if its empty (anticipated on non-Windows platforms).
    foreach (_directory IN ITEMS
                 "${CURRENT_PACKAGES_DIR}/debug/bin/${_python_tool_name}"
                 "${CURRENT_PACKAGES_DIR}/bin/${_python_tool_name}")
        if (NOT IS_DIRECTORY "${_directory}")
            continue()
        endif ()

        file(GLOB _files_in_directory "${_directory}/*")
        if("${_files_in_directory}" STREQUAL "")
            file(REMOVE_RECURSE "${_directory}")
        endif()
    endforeach()
endif ()

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.TXT"
)
file(
    INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)
