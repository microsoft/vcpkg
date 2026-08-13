vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 d6d07db668e62e2c4fb476b549243c240434613554e99bd68b6446b56b92e6cec606246186a02964ed9a223b5ccdac55546185510cd9f6fda05d458314fb05c1
    HEAD_REF master
    PATCHES
        build-tools.patch
        fix-vendor-versions.patch
        fix-imgui-patch.patch
        downgrade-capstone-5.patch # tracy wants capstone-6-alpha but vcpkg ships the most recent production capstone, 5.0.6 as of 2026-02-04
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        on-demand TRACY_ON_DEMAND
        fibers	  TRACY_FIBERS
        verbose   TRACY_VERBOSE
    INVERTED_FEATURES
        crash-handler TRACY_NO_CRASH_HANDLER
)

vcpkg_check_features(OUT_FEATURE_OPTIONS TOOLS_OPTIONS
    FEATURES
        cli-tools VCPKG_CLI_TOOLS
        gui-tools VCPKG_GUI_TOOLS
)

if ("gui-tools" IN_LIST FEATURES)
   vcpkg_from_github(
       OUT_SOURCE_PATH tracy_imgui_path
       REPO ocornut/imgui
       REF "v1.92.9b-docking"
       SHA512 7eddcdb475f1db1fc8242d918533b955c964d2267abe713bdf23f8e2444770946d3c79c7855e360bab6168e36231b95bd05a84106c08f876dcd53daac9caccac
       PATCHES
           "${SOURCE_PATH}/cmake/imgui-emscripten.patch"
           "${SOURCE_PATH}/cmake/imgui-loader.patch"
   )
   list(APPEND TOOLS_OPTIONS "-DImGui_SOURCE_DIR=${tracy_imgui_path}")
endif()

if("cli-tools" IN_LIST FEATURES OR "gui-tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND TOOLS_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DDOWNLOAD_CAPSTONE=OFF
        -DLEGACY=ON
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        ${TOOLS_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        DOWNLOAD_CAPSTONE
        LEGACY
        CMAKE_DISABLE_FIND_PACKAGE_Git
        ImGui_SOURCE_DIR
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME Tracy CONFIG_PATH "lib/cmake/Tracy")

function(tracy_copy_tool tool_name tool_dir)
    vcpkg_copy_tools(
        TOOL_NAMES "${tool_name}"
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/${tool_dir}"
    )
endfunction()

set(TOOLS)
if("cli-tools" IN_LIST FEATURES)
    list(APPEND TOOLS tracy-capture tracy-capture-daemon tracy-csvexport tracy-merge)
    tracy_copy_tool(tracy-import-chrome import)
    tracy_copy_tool(tracy-import-fuchsia import)
    tracy_copy_tool(tracy-update update)
endif()
if("gui-tools" IN_LIST FEATURES)
    list(APPEND TOOLS tracy-profiler)
endif()

if(TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
