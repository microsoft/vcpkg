vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 d3d99284e3c3172236c3f02b3bc52df111ef650fb8609e54fb3302ece28e55a06cd16713ed532f1e1aad66678ff09639dfc7e01a1e96880fb923b267a1b1b79b
    HEAD_REF master
    PATCHES
        build-tools.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        on-demand TRACY_ON_DEMAND
        fibers	  TRACY_FIBERS
        cli-tools VCPKG_CLI_TOOLS
        gui-tools VCPKG_GUI_TOOLS
        verbose   TRACY_VERBOSE
    INVERTED_FEATURES
        crash-handler TRACY_NO_CRASH_HANDLER
)

set(EXTRA_OPTIONS "")
if("cli-tools" IN_LIST FEATURES OR "gui-tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND EXTRA_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDOWNLOAD_CAPSTONE=OFF
        -DLEGACY=ON
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        DOWNLOAD_CAPSTONE
        LEGACY
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME Tracy)

function(tracy_copy_tool tool_name)
    vcpkg_copy_tools(
        TOOL_NAMES "tracy-${tool_name}"
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${tool_name}"
    )
    vcpkg_copy_tools(
        TOOL_NAMES "tracy-${tool_name}"
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/${tool_name}"
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools/${PORT}
    )
endfunction()

if("cli-tools" IN_LIST FEATURES)
    tracy_copy_tool(capture)
    tracy_copy_tool(csvexport)
    tracy_copy_tool(import-chrome)
    tracy_copy_tool(import-fuchsia)
    tracy_copy_tool(update)
endif()
if("gui-tools" IN_LIST FEATURES)
    tracy_copy_tool(profiler)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
