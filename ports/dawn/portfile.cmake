if (VCPKG_TARGET_IS_LINUX AND "x11" IN_LIST FEATURES)
    message(WARNING
[[
dawn support requires the following libraries from the system package manager:

    libxrandr-dev libxinerama-dev libxcursor-dev libx11-xcb-dev mesa-common-dev

They can be installed on Debian based systems via

    apt-get install libxrandr-dev libxinerama-dev libxcursor-dev libx11-xcb-dev mesa-common-dev
]]
    )
endif()

set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
set(VCPKG_POLICY_DLLS_WITHOUT_EXPORTS enabled)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_PATH}")

function(dawn_fetch)
    set(oneValueArgs DESTINATION URL REF SOURCE)
    set(multipleValuesArgs PATCHES)
    cmake_parse_arguments(DAWN "" "${oneValueArgs}" "${multipleValuesArgs}" ${ARGN})

    message(STATUS "Fetching ${DAWN_DESTINATION}...")

    if(NOT DEFINED DAWN_DESTINATION)
        message(FATAL_ERROR "DESTINATION must be specified.")
    endif()

    if(NOT DEFINED DAWN_URL)
        message(FATAL_ERROR "The git url must be specified")
    endif()

    if(NOT DEFINED DAWN_REF)
        message(FATAL_ERROR "The git ref must be specified.")
    endif()

    if(EXISTS "${DAWN_SOURCE}/${DAWN_DESTINATION}/.git")
        vcpkg_execute_required_process(
            COMMAND ${GIT} reset --hard
            WORKING_DIRECTORY ${DAWN_SOURCE}/${DAWN_DESTINATION}
            LOGNAME build-${TARGET_TRIPLET})
    else()
        vcpkg_execute_required_process(
            COMMAND ${GIT} clone --depth 1 ${DAWN_URL} ${DAWN_DESTINATION}
            WORKING_DIRECTORY ${DAWN_SOURCE}
            LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
            COMMAND ${GIT} fetch --depth 1 origin ${DAWN_REF}
            WORKING_DIRECTORY ${DAWN_SOURCE}/${DAWN_DESTINATION}
            LOGNAME build-${TARGET_TRIPLET})
        vcpkg_execute_required_process(
            COMMAND ${GIT} checkout FETCH_HEAD
            WORKING_DIRECTORY ${DAWN_SOURCE}/${DAWN_DESTINATION}
            LOGNAME build-${TARGET_TRIPLET})
    endif()
    foreach(PATCH ${DAWN_PATCHES})
        vcpkg_execute_required_process(
            COMMAND ${GIT} apply ${PATCH}
            WORKING_DIRECTORY ${DAWN_SOURCE}/${DAWN_DESTINATION}
            LOGNAME build-${TARGET_TRIPLET})
    endforeach()
endfunction()

set(DAWN_PATCHES
    remove_partition_alloc_dep.patch # XCode clang was getting libc++ compile errors for partition alloc, given it is an optional dependency and complicates debug builds, lets just disable it on all platforms for now
)
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND DAWN_PATCHES windows_gn_script_py_executable.patch)  # Fixes the following Windows generate failure: ERROR Could not find "python3" from dotfile in PATH.
endif()

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://dawn.googlesource.com/dawn
    REF 26e8bd1105a87e71e6d6c0dfb6f92f9f131f51da
    PATCHES ${DAWN_PATCHES}
)

message(STATUS "Fetching submodules")

set(DAWN_BUILD_PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/macos_build_find_sdk.patch" # Extracted macos portions of https://github.com/microsoft/vcpkg/blame/master/ports/chromium-base/res/0002-build.patch to resolve the configure error "xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance" that occurs in Github Actions CI
    "${CMAKE_CURRENT_LIST_DIR}/macos_fix_toc_extraction.patch" # The bundled clang we download is missing the otool and nm binaries, so we just hardcode to system default
    "${CMAKE_CURRENT_LIST_DIR}/windows_disable_copying_dbghelp.patch" # Fixes error due to CI env not having the expected Windows 10 SDK: Cannot find debugging tools in Windows SDK 10.0.26100.0.  Please reinstall the Windows SDK and select "Debugging Tools".
    "${CMAKE_CURRENT_LIST_DIR}/windows_expose_dynamic_crt_arg.patch" # Fixes *-windows-static-md builds as the default_crt config does not properly handle the combination of building a static lib with the dynamic CRT
)
if (NOT VCPKG_TARGET_IS_LINUX)
    # NOTE: The thin_archive config was only causing linker issues in the vcpkg-ci-skia port for macOS and Windows, but Linux static builds fail if we disable this config
    list(APPEND DAWN_BUILD_PATCHES "${CMAKE_CURRENT_LIST_DIR}/disable_thin_archive.patch")
endif()

# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/build
dawn_fetch(
    DESTINATION build
    URL https://chromium.googlesource.com/chromium/src/build.git
    REF c734cf94f4e1501e80663319392cfbe0ce26dbb1
    SOURCE ${SOURCE_PATH}
    PATCHES ${DAWN_BUILD_PATCHES}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/buildtools
dawn_fetch(
    DESTINATION buildtools
    URL https://chromium.googlesource.com/chromium/src/buildtools.git
    REF bb0dbc354cf9dd386f59a4db38564a21be756cd9
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/testing
dawn_fetch(
    DESTINATION testing
    URL https://chromium.googlesource.com/chromium/src/testing.git
    REF ae9705179f821d1dbd2b0a2ba7a6582faac7f86b
    SOURCE ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/testing_remove_catapult_deps.patch" # Prevents us from having to clone the large catapult repository as we don't use it and it also causes issues on Windows during git fetch due to long paths
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/abseil-cpp
dawn_fetch(
    DESTINATION third_party/abseil-cpp
    URL https://chromium.googlesource.com/chromium/src/third_party/abseil-cpp.git
    REF cae4b6a3990e1431caa09c7b2ed1c76d0dfeab17
    SOURCE ${SOURCE_PATH}
)
# We don't actually invoke depot_tools here, but on Windows the configure step fails without this as it queries some content assuming depot_tools exists in this location
if(VCPKG_TARGET_IS_WINDOWS)
    # https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/depot_tools
    dawn_fetch(
        DESTINATION third_party/depot_tools
        URL https://chromium.googlesource.com/chromium/tools/depot_tools.git
        REF 28358f4020ad58b86301a723807f8254326863c1
        SOURCE ${SOURCE_PATH}
    )
endif()
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/jinja2
dawn_fetch(
    DESTINATION third_party/jinja2
    URL https://chromium.googlesource.com/chromium/src/third_party/jinja2.git
    REF e2d024354e11cc6b041b0cff032d73f0c7e43a07
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/libprotobuf-mutator/src
dawn_fetch(
    DESTINATION third_party/libprotobuf-mutator/src
    URL https://chromium.googlesource.com/external/github.com/google/libprotobuf-mutator.git
    REF 7bf98f78a30b067e22420ff699348f084f802e12
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/protobuf
dawn_fetch(
    DESTINATION third_party/protobuf
    URL https://chromium.googlesource.com/chromium/src/third_party/protobuf.git
    REF 1a4051088b71355d44591172c474304331aaddad
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/markupsafe
dawn_fetch(
    DESTINATION third_party/markupsafe
    URL https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git
    REF 0bad08bb207bbfc1d6f3bbc82b9242b0c50e5794
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/glslang/src
dawn_fetch(
    DESTINATION third_party/glslang/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/glslang.git
    REF eb77189a282b90e9856fc0ed5b08361a70025bec
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/spirv-headers/src
dawn_fetch(
    DESTINATION third_party/spirv-headers/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Headers.git
    REF c8ad050fcb29e42a2f57d9f59e97488f465c436d
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/spirv-tools/src
dawn_fetch(
    DESTINATION third_party/spirv-tools/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/SPIRV-Tools.git
    REF 257a227fbadf8176ea386c7d8fb9b889cbf08640
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/vulkan-headers/src
dawn_fetch(
    DESTINATION third_party/vulkan-headers/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Headers.git
    REF 088a00d81d1fc30ff77aacf31485871aebec7cb2
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/vulkan-loader/src
dawn_fetch(
    DESTINATION third_party/vulkan-loader/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Loader.git
    REF f946876731972cb323b021b78d1921aa9244808b
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/vulkan-utility-libraries/src
dawn_fetch(
    DESTINATION third_party/vulkan-utility-libraries/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-Utility-Libraries.git
    REF dc6f68172430999a96a209ef4700784917dab1a2
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/vulkan-validation-layers/src
dawn_fetch(
    DESTINATION third_party/vulkan-validation-layers/src
    URL https://chromium.googlesource.com/external/github.com/KhronosGroup/Vulkan-ValidationLayers.git
    REF aa1607f891cefd0a338b65bd8f2254e2c4fbf87c
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/third_party/webgpu-headers/src
dawn_fetch(
    DESTINATION third_party/webgpu-headers/src
    URL https://github.com/webgpu-native/webgpu-headers.git
    REF c8b371dd2ff8a2b028fdc0206af5958521181ba8
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/tools/clang
# The official supported compiler is Clang 19+, so we will use clang on all platforms to build.
# I did try to build dawn with GCC on Linux, but it seems to have quite a few build issues which isn't surprising given https://chromium.googlesource.com/chromium/src/+/refs/tags/139.0.7349.88/docs/clang.md#using-gcc-on-linux.
dawn_fetch(
    DESTINATION tools/clang
    URL https://chromium.googlesource.com/chromium/src/tools/clang.git
    REF 7ade8a8f2a759b822022560e08d49b33a2e8496d
    SOURCE ${SOURCE_PATH}
)
# https://dawn.googlesource.com/dawn/+/refs/heads/chromium/7349/tools/protoc_wrapper
dawn_fetch(
    DESTINATION tools/protoc_wrapper
    URL https://chromium.googlesource.com/chromium/src/tools/protoc_wrapper.git
    REF 8ad6d21544b14c7f753852328d71861b363cc512
    SOURCE ${SOURCE_PATH}
)

# gn requires these files but they are only added automatically when using depot_tools (the v8 port does this as well)
file(WRITE "${SOURCE_PATH}/build/config/gclient_args.gni" "checkout_google_benchmark = false\ngenerate_location_tags = false\n")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/LASTCHANGE.committime" DESTINATION "${SOURCE_PATH}/build/util")

# We need to run this before configure to download the bundled clang gn expects to exist
vcpkg_execute_required_process(
    COMMAND ${PYTHON3} tools/clang/scripts/update.py
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build-${TARGET_TRIPLET}
)

set(DAWN_USE_WAYLAND "dawn_use_wayland=false")
set(DAWN_USE_X11 "dawn_use_x11=false")
if("x11" IN_LIST FEATURES)
    set(DAWN_USE_X11 "dawn_use_x11=true")
endif()
if("wayland" IN_LIST FEATURES)
    set(DAWN_USE_WAYLAND "dawn_use_wayland=true")
endif()

set(DAWN_ENABLE_VULKAN "dawn_enable_vulkan=false")
set(DAWN_ENABLE_METAL "dawn_enable_metal=false")
if("vulkan" IN_LIST FEATURES)
    set(DAWN_ENABLE_VULKAN "dawn_enable_vulkan=true")
endif()
if("metal" IN_LIST FEATURES)
    set(DAWN_ENABLE_METAL "dawn_enable_metal=true")
endif()

# Vulkan and Metal backends are enough for now, DirectX would only be required for UWP support
set(DAWN_ENABLE_D3D11 "dawn_enable_d3d11=false")
set(DAWN_ENABLE_D3D12 "dawn_enable_d3d12=false")
set(DAWN_ENABLE_DESKTOP_GL "dawn_enable_desktop_gl=false")
set(DAWN_ENABLE_OPENGLES "dawn_enable_opengles=false")

set(DAWN_FORCE_DYNAMIC_CRT)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(DAWN_COMPLETE_STATIC_LIBS "dawn_complete_static_libs=true")
    if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(DAWN_FORCE_DYNAMIC_CRT "force_dynamic_crt=true")
    endif()

    set(DAWN_PROC_TARGET "src/dawn:proc_static")
    set(DAWN_PROC_LIB "dawn_proc_static")

    set(DAWN_NATIVE_TARGET "src/dawn/native:static")
    set(DAWN_NATIVE_LIB "dawn_native_static")

    set(DAWN_PLATFORM_TARGET "src/dawn/platform:static")
    set(DAWN_PLATFORM_LIB "dawn_platform_static")

    set(DAWN_WEBGPU_TARGET "src/dawn/native:webgpu_dawn_static")
	set(DAWN_WEBGPU_LIB "webgpu_dawn_static")
else()
    set(DAWN_COMPLETE_STATIC_LIBS)

    set(DAWN_PROC_TARGET "src/dawn:proc_shared")
	set(DAWN_PROC_LIB "dawn_proc")
	
    set(DAWN_NATIVE_TARGET "src/dawn/native:shared")
	set(DAWN_NATIVE_LIB "dawn_native")
	
    set(DAWN_PLATFORM_TARGET "src/dawn/platform:shared")
	set(DAWN_PLATFORM_LIB "dawn_platform")
	
    set(DAWN_WEBGPU_TARGET "src/dawn/native:webgpu_dawn_shared")
	set(DAWN_WEBGPU_LIB "webgpu_dawn")
endif()

vcpkg_gn_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "target_cpu=\"${VCPKG_TARGET_ARCHITECTURE}\" use_sysroot=false ${DAWN_FORCE_DYNAMIC_CRT} ${DAWN_COMPLETE_STATIC_LIBS} tint_build_hlsl_writer=false tint_has_fuzzers=false tint_build_unittests=false tint_build_benchmarks=false is_clang=true use_glib=false use_custom_libcxx=false dawn_standalone=true ${DAWN_USE_X11} ${DAWN_USE_WAYLAND} dawn_use_swiftshader=false dawn_tests_use_angle=false ${DAWN_ENABLE_VULKAN} ${DAWN_ENABLE_METAL} ${DAWN_ENABLE_D3D11} ${DAWN_ENABLE_D3D12} ${DAWN_ENABLE_DESKTOP_GL} ${DAWN_ENABLE_OPENGLES}"
    OPTIONS_DEBUG "is_debug=true"
    OPTIONS_RELEASE "is_debug=false"
)

vcpkg_gn_install(
    SOURCE_PATH "${SOURCE_PATH}"
    TARGETS ${DAWN_PROC_TARGET} ${DAWN_NATIVE_TARGET} ${DAWN_PLATFORM_TARGET} ${DAWN_WEBGPU_TARGET}
)

file(INSTALL "${SOURCE_PATH}/include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")

# The generated header targets do exist; however, vcpkg_gn_install installs them to the lib directory, so we need to manually install them to the include directory
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(DAWN_GENERATED_HEADERS_DIR_PREFIX "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg")
    set(DAWN_PKGCONFIG_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(DAWN_GENERATED_HEADERS_DIR_PREFIX "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel")
    set(DAWN_PKGCONFIG_DIR "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
set(DAWN_GENERATED_HEADERS_DIR "${DAWN_GENERATED_HEADERS_DIR_PREFIX}/gen/include/dawn")
set(WEBGPU_GENERATED_HEADERS_DIR "${DAWN_GENERATED_HEADERS_DIR_PREFIX}/gen/include/webgpu")

# These are the headers output by the following commands:
#   - `gn desc <build_dir> include/dawn:headers_gen outputs`
#   - `gn desc <build_dir> include/dawn:cpp_headers_gen outputs`
set(DAWN_GENERATED_HEADER_FILES
    "${DAWN_GENERATED_HEADERS_DIR}/dawn_proc_table.h"
    "${DAWN_GENERATED_HEADERS_DIR}/webgpu.h"
    "${DAWN_GENERATED_HEADERS_DIR}/webgpu_cpp.h"
    "${DAWN_GENERATED_HEADERS_DIR}/webgpu_cpp_print.h"
)
set(WEBGPU_GENERATED_HEADER_FILES
    "${WEBGPU_GENERATED_HEADERS_DIR}/webgpu_cpp_chained_struct.h"
)
# Unfortunately some convoluted manual header organization is required here to put things in the right place for consumers that `#include <webgpu/webgpu_cpp.h>`
file(INSTALL ${WEBGPU_GENERATED_HEADERS_DIR} DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL ${DAWN_GENERATED_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/dawn")
file(INSTALL ${DAWN_GENERATED_HEADER_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/include/webgpu/dawn")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(DAWN_PKGCONFIG_DIR "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
    file(MAKE_DIRECTORY "${DAWN_PKGCONFIG_DIR}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-proc.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-proc.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-native.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-native.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-platform.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-platform.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-webgpu-dawn.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-webgpu-dawn.pc" @ONLY)
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(DAWN_PKGCONFIG_DIR "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
    file(MAKE_DIRECTORY "${DAWN_PKGCONFIG_DIR}")
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-proc.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-proc.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-native.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-native.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-dawn-platform.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-dawn-platform.pc" @ONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-webgpu-dawn.pc.in" "${DAWN_PKGCONFIG_DIR}/unofficial-webgpu-dawn.pc" @ONLY)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
