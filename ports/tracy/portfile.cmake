vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 18c0c589a1d97d0760958c8ab00ba2135bc602fd359d48445b5d8ed76e5b08742d818bb8f835b599149030f455e553a92db86fb7bae049b47820e4401cf9f935
    HEAD_REF master
    PATCHES
        build-tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        on-demand TRACY_ON_DEMAND
        fibers    TRACY_FIBERS
        verbose   TRACY_VERBOSE
    INVERTED_FEATURES
        crash-handler TRACY_NO_CRASH_HANDLER
)

vcpkg_check_features(OUT_FEATURE_OPTIONS TOOLS_OPTIONS
    FEATURES
        cli-tools VCPKG_CLI_TOOLS
        gui-tools VCPKG_GUI_TOOLS
)

if("cli-tools" IN_LIST FEATURES OR "gui-tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND TOOLS_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDOWNLOAD_CAPSTONE=OFF
        -DLEGACY=ON
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        ${TOOLS_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        DOWNLOAD_CAPSTONE
        LEGACY
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/include/tracy/tracy")
    message(STATUS "Flattening include/tracy/tracy...")

    file(GLOB INNER_FILES "${CURRENT_PACKAGES_DIR}/include/tracy/tracy/*")
    file(COPY ${INNER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/tracy")

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/tracy/tracy")
endif()

message(STATUS "Patching headers to fix relative includes...")
file(GLOB_RECURSE TRACY_HEADERS "${CURRENT_PACKAGES_DIR}/include/tracy/*.hpp" "${CURRENT_PACKAGES_DIR}/include/tracy/*.h")

foreach(HEADER ${TRACY_HEADERS})
    file(READ "${HEADER}" _contents)

    string(REPLACE "../common" "common" _contents "${_contents}")
    string(REPLACE "../client" "client" _contents "${_contents}")
    string(REPLACE "../libbacktrace" "libbacktrace" _contents "${_contents}")

    file(WRITE "${HEADER}" "${_contents}")
endforeach()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME Tracy
    CONFIG_PATH lib/cmake/Tracy
)

function(tracy_copy_tool tool_name tool_dir)
    vcpkg_copy_tools(
        TOOL_NAMES "${tool_name}"
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${tool_dir}"
    )
endfunction()

if("cli-tools" IN_LIST FEATURES)
    tracy_copy_tool(tracy-capture capture)
    tracy_copy_tool(tracy-csvexport csvexport)
    tracy_copy_tool(tracy-import-chrome import)
    tracy_copy_tool(tracy-import-fuchsia import)
    tracy_copy_tool(tracy-update update)
endif()
if("gui-tools" IN_LIST FEATURES)
    tracy_copy_tool(tracy-profiler profiler)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
