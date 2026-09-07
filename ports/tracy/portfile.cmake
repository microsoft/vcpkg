vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 53912d7563e595812b37bc55fd40508cfd8e5c42d48d957a73b6b7d18bf1287b3f795c10c9a986bf7b906d5b5bebe13b02216e563e794d0a82b2783e8ce5510b
    HEAD_REF master
    PATCHES
        fix-debug-install-dirs.patch # vcpkg splits debug/release prefixes; upstream nests non-Release output in a $<CONFIG> subdir (microsoft/vcpkg#52343)
        build-tools.patch
        fix-vendor-versions.patch
        downgrade-capstone-5.patch # tracy wants capstone-6-alpha but vcpkg ships the most recent production capstone, 5.0.9 as of 2026-09-07
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
           "${CURRENT_PORT_DIR}/imgui-loader.patch" # upstream's copy has stale line numbers that git apply rejects
           "${SOURCE_PATH}/cmake/imgui-no-samplers.patch"
           "${SOURCE_PATH}/cmake/imgui-no-default-font.patch"
           "${SOURCE_PATH}/cmake/imgui-macos-clipboard.patch"
           "${SOURCE_PATH}/cmake/imgui-phantom-column.patch"
   )
   list(APPEND TOOLS_OPTIONS "-DImGui_SOURCE_DIR=${tracy_imgui_path}")

   # Not the md4c port: 0.5.3 predates the footnote API tracy 0.14 uses, and md4c
   # has no newer release. Pinned to the same commit upstream tracy pins.
   vcpkg_from_github(
       OUT_SOURCE_PATH tracy_md4c_path
       REPO mity/md4c
       REF 65c6c9d72cebd9a731aaa5597414ce04d9ea5de3
       SHA512 4a4971d340f44238259c97eadc08f84fec180bc24db3b4db1d997a08d11e36a47ae10a2b127fb7d149a33b326bf6bc43ab71dc664d5f6bf9ea83ca111ebcacc9
   )
   list(APPEND TOOLS_OPTIONS "-Dmd4c_SOURCE_DIR=${tracy_md4c_path}")

   # tracy-profiler statically links imgui and md4c
   list(APPEND extra_copyright "${tracy_imgui_path}/LICENSE.txt" "${tracy_md4c_path}/LICENSE.md")
endif()

if("cli-tools" IN_LIST FEATURES OR "gui-tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND TOOLS_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DLEGACY=ON
        -DCMAKE_FIND_PACKAGE_TARGETS_GLOBAL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON # embeds a git hash in the binaries; see build-tools.patch
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        ${TOOLS_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        LEGACY
        CMAKE_DISABLE_FIND_PACKAGE_Git
        ImGui_SOURCE_DIR
        md4c_SOURCE_DIR
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME Tracy CONFIG_PATH "lib/cmake/Tracy")

set(TOOLS)
if("cli-tools" IN_LIST FEATURES)
    list(APPEND TOOLS tracy-capture tracy-capture-daemon tracy-csvexport tracy-merge tracy-update)
    # tracy-import-* have no install() rule upstream; take them from the build tree.
    vcpkg_copy_tools(
        TOOL_NAMES tracy-import-chrome tracy-import-fuchsia
        SEARCH_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/import"
    )
endif()
if("gui-tools" IN_LIST FEATURES)
    list(APPEND TOOLS tracy-profiler)
endif()

if(TOOLS)
    vcpkg_copy_tools(TOOL_NAMES ${TOOLS} AUTO_CLEAN)
endif()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" ${extra_copyright})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
