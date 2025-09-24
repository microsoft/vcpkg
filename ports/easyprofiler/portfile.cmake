vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yse/easy_profiler
    REF "v${VERSION}"
    SHA512 101d84a903315456ac24d060da6269e02ac0030e966b801910543c39980042e92082b2430daaa9ab48ced90fb5fc0adf43dfab647615742d32950a1667c3630f
    HEAD_REF develop
    PATCHES
        fixifwin32.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        gui EASY_PROFILER_NO_GUI
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP)
    set(HAS_WIN32 ON)
else()
    set(HAS_WIN32 OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEASY_PROFILER_NO_SAMPLES=ON
	-DWIN32=${HAS_WIN32}
	-DEASY_OPTION_EVENT_TRACING=${HAS_WIN32}
	-DEASY_OPTION_LOW_PRIORITY_EVENT_TRACING=${HAS_WIN32}
)

vcpkg_cmake_install()

vcpkg_copy_tools(
    TOOL_NAMES "profiler_converter"
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/easy_profiler"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.APACHE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE.MIT")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.APACHE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE.MIT")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/easy_profiler_core/LICENSE.MIT"
    "${SOURCE_PATH}/easy_profiler_core/LICENSE.APACHE")
