vcpkg_download_distfile(PATCH_MISSING_CHRONO_INCLUDE
    URLS https://github.com/wolfpld/tracy/commit/50ff279aaddfd91dc3cdcfd5b7aec3978e63da25.diff?full_index=1
    SHA512 f9594297ea68612b68bd631497cd312ea01b34280a0f098de0d2b99810149345251a8985a6430337d0b55d2f181ceac10d563b64cfe48f78959f79ec7a6ea3b5
    FILENAME wolfpld-tracy-PR982.diff
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 d3d99284e3c3172236c3f02b3bc52df111ef650fb8609e54fb3302ece28e55a06cd16713ed532f1e1aad66678ff09639dfc7e01a1e96880fb923b267a1b1b79b
    HEAD_REF master
    PATCHES
        build-tools.patch
		"${PATCH_MISSING_CHRONO_INCLUDE}"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        on-demand                        TRACY_ON_DEMAND
        fibers                           TRACY_FIBERS
        verbose                          TRACY_VERBOSE
        delayed-init                     TRACY_DELAYED_INIT
        manual-lifetime                  TRACY_MANUAL_LIFETIME
        manual-lifetime                  TRACY_DELAYED_INIT # TRACY_DELAYED_INIT augments TRACY_MANUAL_LIFETIME
        no-callstack                     TRACY_NO_CALLSTACK
        no-callstack-inlines             TRACY_NO_CALLSTACK_INLINES
        only-localhost                   TRACY_ONLY_LOCALHOST
        no-broadcast                     TRACY_NO_BROADCAST
        only-ipv4                        TRACY_ONLY_IPV4
        no-code-transfer                 TRACY_NO_CODE_TRANSFER
        no-context-switch                TRACY_NO_CONTEXT_SWITCH
        no-exit                          TRACY_NO_EXIT
        no-sampling                      TRACY_NO_SAMPLING
        no-verify                        TRACY_NO_VERIFY
        no-vsync-capture                 TRACY_NO_VSYNC_CAPTURE
        no-frame-image                   TRACY_NO_FRAME_IMAGE
        no-system-tracing                TRACY_NO_SYSTEM_TRACING
        patchable-nopsleds               TRACY_PATCHABLE_NOPSLEDS
        timer-fallback                   TRACY_TIMER_FALLBACK
        symbol-offline-resolve           TRACY_SYMBOL_OFFLINE_RESOLVE

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
vcpkg_cmake_config_fixup(PACKAGE_NAME Tracy)

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
