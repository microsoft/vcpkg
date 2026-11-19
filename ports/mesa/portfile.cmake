vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # some parts of this port can only build as a shared library.
endif()

set(MESA_HAS_OUTPUT OFF)
foreach(feature IN ITEMS opengl gles1 gles2 egl lavapipe kosmickrisp dozen radv anv turnip honeykrisp panvk v3dv)
    if(feature IN_LIST FEATURES)
        set(MESA_HAS_OUTPUT ON)
        break()
    endif()
endforeach()
if(NOT MESA_HAS_OUTPUT)
    message(STATUS "No client API or Vulkan driver feature selected, nothing to build.")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

if((VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX) AND "opengl" IN_LIST FEATURES AND NOT "x11" IN_LIST FEATURES AND NOT "egl" IN_LIST FEATURES)
    message(FATAL_ERROR "Feature 'opengl' requires feature 'x11' or 'egl'.")
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF "mesa-${VERSION}"
    SHA512 6fb28eac175d007f95aa2b4d790e01af2e14d6c73b1ef4e9e58849cce022e82eb79a71ee2cdae67285d61cea0c2a80de4c12a5aa888beaded273c0ac4d9cd949
    FILE_DISAMBIGUATOR 1
    HEAD_REF master
    PATCHES
        001-windows-gles-dispatch.patch
        001-warnings-not-errors.patch
        002-clang-resource-dir.patch
        003-spirv-llvm-translator-cmake.patch
)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" OUT_PYTHON_VAR "PYTHON3" PACKAGES setuptools mako pyyaml)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${PYTHON3_DIR}")

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

if(CMAKE_HOST_WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        if(FLEX_DIR MATCHES "${DOWNLOADS}")
            file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        else()
            message(FATAL_ERROR "${PORT} requires flex being named flex on windows and not win_flex!\n(Can be solved by creating a simple link from win_flex to flex)")
        endif()
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        if(BISON_DIR MATCHES "${DOWNLOADS}")
            file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        else()
            message(FATAL_ERROR "${PORT} requires bison being named bison on windows and not win_bison!\n(Can be solved by creating a simple link from win_bison to bison)")
        endif()
    endif()
endif()

# For features https://github.com/pal1000/mesa-dist-win should be probably studied a bit more.
list(APPEND MESA_OPTIONS -Dzstd=enabled)
list(APPEND MESA_OPTIONS -Dvalgrind=disabled)
list(APPEND MESA_OPTIONS -Ddisplay-info=disabled)
list(APPEND MESA_OPTIONS -Dshared-llvm=disabled)
list(APPEND MESA_OPTIONS -Dcpp_rtti=true)
# Pin options that would otherwise be auto-detected from the system.
list(APPEND MESA_OPTIONS -Dgallium-va=disabled)
list(APPEND MESA_OPTIONS -Dlibunwind=disabled)
list(APPEND MESA_OPTIONS -Dlmsensors=disabled)
list(APPEND MESA_OPTIONS -Dglvnd=disabled)
list(APPEND MESA_OPTIONS -Damd-use-llvm=false)
list(APPEND MESA_OPTIONS -Dpanfrost-rust=false)
if(VCPKG_TARGET_IS_LINUX)
    list(APPEND MESA_OPTIONS -Dexpat=enabled -Dxmlconfig=enabled)
else()
    list(APPEND MESA_OPTIONS -Dexpat=disabled -Dxmlconfig=disabled)
endif()

function(mesa_meson_array out_var)
    set(quoted "")
    foreach(item IN LISTS ARGN)
        list(APPEND quoted "'${item}'")
    endforeach()
    list(JOIN quoted "," joined)
    set(${out_var} "[${joined}]" PARENT_SCOPE)
endfunction()

macro(mesa_feature_option feature option)
    if("${feature}" IN_LIST FEATURES)
        list(APPEND MESA_OPTIONS "-D${option}=enabled")
    else()
        list(APPEND MESA_OPTIONS "-D${option}=disabled")
    endif()
endmacro()

# Client APIs
mesa_feature_option(gles1 gles1)
mesa_feature_option(gles2 gles2)
mesa_feature_option(egl egl)
mesa_feature_option(gbm gbm)
if("opengl" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dopengl=true)
else()
    list(APPEND MESA_OPTIONS -Dopengl=false)
endif()
if("opengl" IN_LIST FEATURES AND "x11" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dglx=dri)
else()
    list(APPEND MESA_OPTIONS -Dglx=disabled)
endif()

# Gallium drivers (same feature name as the driver name)
set(MESA_GALLIUM_DRIVERS "")
foreach(driver IN ITEMS llvmpipe softpipe zink d3d12 radeonsi iris nouveau virgl svga freedreno asahi panfrost v3d)
    if(driver IN_LIST FEATURES)
        list(APPEND MESA_GALLIUM_DRIVERS "${driver}")
    endif()
endforeach()
if(NOT MESA_GALLIUM_DRIVERS)
    foreach(api IN ITEMS opengl gles1 gles2 egl)
        if(api IN_LIST FEATURES)
            message(FATAL_ERROR "Feature '${api}' requires at least one Gallium driver feature (e.g. llvmpipe or softpipe).")
        endif()
    endforeach()
endif()
mesa_meson_array(MESA_GALLIUM_DRIVERS ${MESA_GALLIUM_DRIVERS})
list(APPEND MESA_OPTIONS "-Dgallium-drivers=${MESA_GALLIUM_DRIVERS}")

# Vulkan drivers (feature name to driver name)
set(MESA_VULKAN_DRIVERS "")
foreach(entry IN ITEMS
    lavapipe:swrast
    kosmickrisp:kosmickrisp
    dozen:microsoft-experimental
    radv:amd
    anv:intel
    turnip:freedreno
    honeykrisp:asahi
    panvk:panfrost
    v3dv:broadcom
)
    string(REPLACE ":" ";" entry "${entry}")
    list(GET entry 0 feature)
    list(GET entry 1 driver)
    if(feature IN_LIST FEATURES)
        list(APPEND MESA_VULKAN_DRIVERS "${driver}")
    endif()
endforeach()
if(MESA_VULKAN_DRIVERS)
    # Install a single ICD manifest per driver (e.g. lvp_icd.json) instead of one per architecture
    # (e.g. lvp_icd.x86_64.json), since a vcpkg installed tree only contains one architecture.
    list(APPEND MESA_OPTIONS -Dvulkan-manifest-per-architecture=false)
endif()
mesa_meson_array(MESA_VULKAN_DRIVERS ${MESA_VULKAN_DRIVERS})
list(APPEND MESA_OPTIONS "-Dvulkan-drivers=${MESA_VULKAN_DRIVERS}")

# These Vulkan drivers compile BVH shaders with glslang.
foreach(feature IN ITEMS lavapipe radv anv turnip)
    if(feature IN_LIST FEATURES)
        list(APPEND MESA_NATIVE_BINARIES
            "glslangValidator=['${CURRENT_HOST_INSTALLED_DIR}/tools/glslang/glslangValidator${VCPKG_HOST_EXECUTABLE_SUFFIX}']"
        )
        break()
    endif()
endforeach()

# Platforms
if(VCPKG_TARGET_IS_WINDOWS)
    set(MESA_PLATFORMS windows)
elseif(VCPKG_TARGET_IS_OSX)
    set(MESA_PLATFORMS macos)
    if("x11" IN_LIST FEATURES)
        list(APPEND MESA_PLATFORMS x11)
    endif()
elseif(VCPKG_TARGET_IS_ANDROID)
    set(MESA_PLATFORMS android)
else()
    set(MESA_PLATFORMS "")
    if("x11" IN_LIST FEATURES)
        list(APPEND MESA_PLATFORMS x11)
    endif()
    if("wayland" IN_LIST FEATURES)
        list(APPEND MESA_PLATFORMS wayland)
        if(X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES)
            list(APPEND MESA_NATIVE_BINARIES
                "wayland-scanner=['${CURRENT_HOST_INSTALLED_DIR}/tools/wayland/wayland-scanner${VCPKG_HOST_EXECUTABLE_SUFFIX}']"
            )
        endif()
    endif()
endif()
mesa_meson_array(MESA_PLATFORMS ${MESA_PLATFORMS})
list(APPEND MESA_OPTIONS "-Dplatforms=${MESA_PLATFORMS}")
mesa_feature_option(x11 xlib-lease)

# Build tools are looked up with find_program(native : true), which only uses native files.
if(MESA_NATIVE_BINARIES)
    list(JOIN MESA_NATIVE_BINARIES "\n" MESA_NATIVE_BINARIES)
    set(MESA_NATIVE_FILE "${CURRENT_BUILDTREES_DIR}/mesa-native-tools.ini")
    file(WRITE "${MESA_NATIVE_FILE}" "[binaries]\n${MESA_NATIVE_BINARIES}\n")
    list(APPEND MESA_OPTIONS --native "${MESA_NATIVE_FILE}")
endif()

# LLVM and CLC
if("llvm" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dllvm=enabled)
    set(LLVM_CONFIG_DEBUG_NATIVE_FILE "${CURRENT_BUILDTREES_DIR}/llvm-config-debug.ini")
    set(LLVM_CONFIG_RELEASE_NATIVE_FILE "${CURRENT_BUILDTREES_DIR}/llvm-config-release.ini")
    file(WRITE "${LLVM_CONFIG_DEBUG_NATIVE_FILE}"
        "[binaries]\nllvm-config = ['${CURRENT_INSTALLED_DIR}/debug/tools/llvm/llvm-config${VCPKG_TARGET_EXECUTABLE_SUFFIX}']\n"
    )
    file(WRITE "${LLVM_CONFIG_RELEASE_NATIVE_FILE}"
        "[binaries]\nllvm-config = ['${CURRENT_INSTALLED_DIR}/tools/llvm/llvm-config${VCPKG_TARGET_EXECUTABLE_SUFFIX}']\n"
    )
    list(APPEND MESA_OPTIONS_DEBUG --native "${LLVM_CONFIG_DEBUG_NATIVE_FILE}")
    list(APPEND MESA_OPTIONS_RELEASE --native "${LLVM_CONFIG_RELEASE_NATIVE_FILE}")
else()
    list(APPEND MESA_OPTIONS -Dllvm=disabled)
endif()
mesa_feature_option(clc spirv-tools)

# Libraries which must be provided by the system
if(VCPKG_TARGET_IS_LINUX)
    message(WARNING "You will need to install libdrm dependencies to use this port:\nsudo apt install libdrm-dev\n")
    if("x11" IN_LIST FEATURES)
        message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libxshmfence-dev\n")
    endif()
    if("wayland" IN_LIST FEATURES AND "egl" IN_LIST FEATURES AND NOT X_VCPKG_FORCE_VCPKG_WAYLAND_LIBRARIES)
        message(WARNING "You will need to install Wayland EGL dependencies to use features wayland and egl together:\nsudo apt install libwayland-egl-backend-dev\n")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MESA_OPTIONS -Dmicrosoft-clc=disabled)
    if(NOT VCPKG_TARGET_IS_MINGW)
        set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
        set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
    endif()
elseif(VCPKG_TARGET_IS_ANDROID)
    # Do not let target dependency detection fall back to the build machine's
    # system pkg-config directories while cross-compiling.
    set(MESA_EMPTY_PKG_CONFIG_DIR "${CURRENT_BUILDTREES_DIR}/empty-pkgconfig")
    file(MAKE_DIRECTORY "${MESA_EMPTY_PKG_CONFIG_DIR}")
    list(APPEND MESA_ADDITIONAL_PROPERTIES
        "pkg_config_libdir = ['${MESA_EMPTY_PKG_CONFIG_DIR}']"
    )
    list(APPEND MESA_OPTIONS -Dandroid-stub=true)
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dgles-lib-suffix=_mesa
        -Dbuild-tests=false
        ${MESA_OPTIONS}
    OPTIONS_DEBUG
        ${MESA_OPTIONS_DEBUG}
    OPTIONS_RELEASE
        ${MESA_OPTIONS_RELEASE}
    ADDITIONAL_BINARIES
        python=['${PYTHON3}','-E','-s']
        python3=['${PYTHON3}','-E','-s']
        ${MESA_ADDITIONAL_BINARIES}
    ADDITIONAL_PROPERTIES
        ${MESA_ADDITIONAL_PROPERTIES}
)
vcpkg_install_meson()
if("dozen" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES spirv2dxil AUTO_CLEAN)
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    # installed by egl-registry
    "${CURRENT_PACKAGES_DIR}/include/KHR"
    "${CURRENT_PACKAGES_DIR}/include/EGL"
    # installed by opengl-registry
    "${CURRENT_PACKAGES_DIR}/include/GL"
    "${CURRENT_PACKAGES_DIR}/include/GLES"
    "${CURRENT_PACKAGES_DIR}/include/GLES2"
    "${CURRENT_PACKAGES_DIR}/include/GLES3"
)
file(GLOB remaining "${CURRENT_PACKAGES_DIR}/include/*")
if(NOT remaining)
    # All headers to be provided by egl-registry and/or opengl-registry
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug")
    file(GLOB debug_remaining "${CURRENT_PACKAGES_DIR}/debug/*")
    if(NOT debug_remaining)
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    # opengl32.lib is already installed by port opengl.
    # Mesa claims to provide a drop-in replacement of opengl32.dll.
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/opengl32.lib")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/opengl32.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/opengl32.lib")
    endif()
    if(NOT VCPKG_BUILD_TYPE AND EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/opengl32.lib")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/opengl32.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/opengl32.lib")
    endif()
endif()

set(MESA_USAGE "")
foreach(driver IN ITEMS lavapipe kosmickrisp)
    if(driver IN_LIST FEATURES)
        file(READ "${CMAKE_CURRENT_LIST_DIR}/${driver}-usage" driver_usage)
        string(APPEND MESA_USAGE "${driver_usage}")
    endif()
endforeach()
if(MESA_USAGE)
    file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${MESA_USAGE}")
endif()

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/docs/license.rst"
        "${SOURCE_PATH}/licenses/Apache-2.0"
        "${SOURCE_PATH}/licenses/BSL-1.0"
        "${SOURCE_PATH}/licenses/MIT"
        "${SOURCE_PATH}/licenses/SGI-B-2.0"
        "${SOURCE_PATH}/src/util/softfloat.h"
        "${SOURCE_PATH}/src/util/xxhash.h"
)
