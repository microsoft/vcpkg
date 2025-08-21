vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO carnegierobotics/LibMultiSense
    REF ${VERSION}
    SHA512 69472f288de46c0ecdbbbcb8c280610c1c80778d660098e3b639ab653b108096c3fb4cd92a21afd4745b959a0c80812c5bf2d42053760bbceeafd90e67c20388
    HEAD_REF master
    PATCHES
        0000-platform-specific-links.patch
        0001-find-public-api-dependencies.patch
        0002-disable-error-on-warning.patch
        0003-utilities-cc-unreachable-code.patch
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

if ("utilities" IN_LIST FEATURES)
    set(_tool_names
        ChangeIpUtility
        ImageCalUtility
        PointCloudUtility
        RectifiedFocalLengthUtility
        SaveImageUtility
        VersionInfoUtility
    )
    if ("json-serialization" IN_LIST FEATURES)
        list(APPEND _tool_names DeviceInfoUtility)
    endif ()
    vcpkg_copy_tools(
        TOOL_NAMES ${_tool_names}
        AUTO_CLEAN
    )

    # Python equivalents of the above tools are also installed into bin.  These tools are duplicates and require that
    # the Python bindings be built, which we are not doing.  Since they provide no additional functionality, remove
    # them.
    set(_python_tool_names
        change_ip_utility.py
        device_info_utility.py
        image_cal_utility.py
        point_cloud_utility.py
        rectified_focal_length_utility.py
        save_image_utility.py
        version_info_utility.py
    )
    foreach (_python_tool_name IN LISTS _python_tool_names)
        file(
            REMOVE
                "${CURRENT_PACKAGES_DIR}/debug/bin/${_python_tool_name}"
                "${CURRENT_PACKAGES_DIR}/bin/${_python_tool_name}"
        )
    endforeach ()

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
