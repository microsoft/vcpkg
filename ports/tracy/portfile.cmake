vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfpld/tracy
    REF "v${VERSION}"
    SHA512 a274fbb62ec25ab9b6025eeeb6e0458ba282fe61509dcd0daf824bdbcf3215c25eb992271d33cc88544068f83e00d791833e980eed7c8f4a1cd3ef71841cf38e
    HEAD_REF master
    PATCHES
        fix-debug-install-dirs.patch # vcpkg splits debug/release prefixes; upstream nests non-Release output in a $<CONFIG> subdir (microsoft/vcpkg#52343)
        build-tools.patch
        fix-vendor-versions.patch
        fix-manual-pandoc.patch # upstream downloads pandoc into the user cache at configure time; the port provides it via TRACY_PANDOC
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

set(extra_copyright
    "${SOURCE_PATH}/public/client/tracy_concurrentqueue.h"
    "${SOURCE_PATH}/public/client/tracy_SPSCQueue.h"
    "${SOURCE_PATH}/public/common/tracy_lz4.hpp"
)
if(NOT VCPKG_TARGET_IS_WINDOWS)
    list(APPEND extra_copyright "${SOURCE_PATH}/public/libbacktrace/LICENSE")
endif()

if ("gui-tools" IN_LIST FEATURES)
   vcpkg_from_github(
       OUT_SOURCE_PATH tracy_imgui_path
       REPO ocornut/imgui
       REF "v1.93.0-docking"
       SHA512 00ade7a3e2c2e34465f1bb9fafd78733d3e659617b0857cf1b3c7f04cfc1d8566d1fd6a8697946f0de7c808cce1c4d0a4b2195c7bc20144cfd8b1e9b1cfba621
       PATCHES
           "${SOURCE_PATH}/cmake/imgui-emscripten.patch"
           "${CURRENT_PORT_DIR}/imgui-loader.patch" # upstream's copy has stale line numbers that git apply rejects
           "${SOURCE_PATH}/cmake/imgui-no-samplers.patch"
           "${SOURCE_PATH}/cmake/imgui-no-default-font.patch"
           "${SOURCE_PATH}/cmake/imgui-macos-clipboard.patch"
           "${SOURCE_PATH}/cmake/imgui-phantom-column.patch"
   )
   list(APPEND TOOLS_OPTIONS "-DImGui_SOURCE_DIR=${tracy_imgui_path}")

   # tracy-profiler statically links imgui
   list(APPEND extra_copyright "${tracy_imgui_path}/LICENSE.txt")

   # The profiler's embedded user manual is generated at build time with python and the exact pandoc version upstream pins.
   vcpkg_find_acquire_program(PYTHON3)
   list(APPEND TOOLS_OPTIONS "-DPython3_EXECUTABLE=${PYTHON3}")

   if(TRACY_PANDOC)
       list(APPEND TOOLS_OPTIONS "-DTRACY_PANDOC=${TRACY_PANDOC}")
   else()
       set(pandoc_version 3.12.1)
       cmake_host_system_information(RESULT pandoc_host_arch QUERY OS_PLATFORM)
       string(TOLOWER "${pandoc_host_arch}" pandoc_host_arch)
       if(VCPKG_HOST_IS_WINDOWS)
           # pandoc only has x86_64 windows prebuilds available
           # we can just run it on ARM64 through emulation but we won't be able to run it on 32bit systems
           if(NOT pandoc_host_arch MATCHES "^(x86_64|amd64|arm64)$")
              message(FATAL_ERROR "tracy[gui-tools] requires pandoc ${pandoc_version}, which has no prebuilt binary for this host (${pandoc_host_arch}).")
           endif()
           set(pandoc_asset "pandoc-${pandoc_version}-windows-x86_64.zip")
           set(pandoc_sha512 7a81ebeada6df48010a40f572e9dd1e6feb7570588c44a4ddecc377738203aa4fe8fa673be97d3feeb61c143b7bb1f71dcfd23828404954c11342874851b029a)
           set(pandoc_exe "pandoc-${pandoc_version}/pandoc.exe")
       else()
           if(VCPKG_HOST_IS_OSX AND pandoc_host_arch MATCHES "^(arm64|aarch64)$")
               set(pandoc_asset "pandoc-${pandoc_version}-arm64-macOS.zip")
               set(pandoc_sha512 a5a33fdf60e8d7e1b388f4e5db451fc5726611bac899ed3d32d7c57940ef8bc36d792f345f44fd44f015a5689daf5b23ccf0e30dd3e121eaedae1b6a7af9e2f5)
               set(pandoc_exe "pandoc-${pandoc_version}-arm64/bin/pandoc")
           elseif(VCPKG_HOST_IS_OSX AND pandoc_host_arch MATCHES "^(x86_64|amd64)$")
               set(pandoc_asset "pandoc-${pandoc_version}-x86_64-macOS.zip")
               set(pandoc_sha512 fe1c0a14f827c07bd2bea91e5d7fac33c89708088fab6e8471625b9da1c3618c8a76d464d7ac2d0475575053964e66ce4f2e778856568a3f3b9d65bf44af7b7a)
               set(pandoc_exe "pandoc-${pandoc_version}-x86_64/bin/pandoc")
           elseif(VCPKG_HOST_IS_LINUX AND pandoc_host_arch MATCHES "^(arm64|aarch64)$")
               set(pandoc_asset "pandoc-${pandoc_version}-linux-arm64.tar.gz")
               set(pandoc_sha512 1a0c12ec4e82143d1a11e3af3465a6b24a9e6c373e3e58e29fd36a81ff45f97edd64c34366c9b01bcf49cd2f6e53b618e0df78f6bf30696f96a674d1c9edea31)
               set(pandoc_exe "pandoc-${pandoc_version}/bin/pandoc")
           elseif(VCPKG_HOST_IS_LINUX AND pandoc_host_arch MATCHES "^(x86_64|amd64)$")
               set(pandoc_asset "pandoc-${pandoc_version}-linux-amd64.tar.gz")
               set(pandoc_sha512 543e16bbfa6feadb3d768efb8bbd06dd58b0ebff24000d2019f8fa7a5af33e992806c435f6a18ccd2149341df18f598a8055d195d213e74914401a4549b01184)
               set(pandoc_exe "pandoc-${pandoc_version}/bin/pandoc")
           else()
               message(FATAL_ERROR "tracy[gui-tools] requires pandoc ${pandoc_version}, which has no prebuilt binary for this host (${pandoc_host_arch}).")
           endif()
       endif()
       vcpkg_download_distfile(pandoc_archive
           URLS "https://github.com/jgm/pandoc/releases/download/${pandoc_version}/${pandoc_asset}"
           FILENAME "${pandoc_asset}"
           SHA512 "${pandoc_sha512}"
       )
       vcpkg_extract_source_archive(pandoc_path
           ARCHIVE "${pandoc_archive}"
           NO_REMOVE_ONE_LEVEL
       )
       list(APPEND TOOLS_OPTIONS "-DTRACY_PANDOC=${pandoc_path}/${pandoc_exe}")
   endif()
endif()

if("cli-tools" IN_LIST FEATURES OR "gui-tools" IN_LIST FEATURES)
    vcpkg_find_acquire_program(PKGCONFIG)
    list(APPEND TOOLS_OPTIONS "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DTRACY_ENABLE=ON # upstream default changed to OFF in 0.14.0
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
