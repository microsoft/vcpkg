vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # some parts of this port can only build as a shared library.
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF mesa-${VERSION}
    SHA512 ed886a0dee1fc9bea11dad8949dfbc9a47f9a925f4e9a2238b6fbe81cffc01e684539e789e75e0eba54a4b563ed212d17bdd4e55af49a40055a64383e67e1136
    FILE_DISAMBIGUATOR 1
    HEAD_REF master
    PATCHES
        001-windows-gles-dispatch.patch
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

if((VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID) AND "llvm" IN_LIST FEATURES)
    list(APPEND MESA_ADDITIONAL_BINARIES
        "glslangValidator=['${CURRENT_HOST_INSTALLED_DIR}/tools/glslang/glslangValidator${VCPKG_HOST_EXECUTABLE_SUFFIX}']"
    )
endif()

if("llvm" IN_LIST FEATURES OR VCPKG_TARGET_IS_WINDOWS)
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
    if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_ANDROID)
        list(APPEND MESA_OPTIONS "-Dvulkan-drivers=[]")
    endif()
endif()

if("gles1" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dgles1=enabled)
else()
    list(APPEND MESA_OPTIONS -Dgles1=disabled)
endif()
if("gles2" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dgles2=enabled)
else()
    list(APPEND MESA_OPTIONS -Dgles2=disabled)
endif()

if("egl" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Degl=enabled)
else()
    list(APPEND MESA_OPTIONS -Degl=disabled)
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MESA_OPTIONS -Dplatforms=['windows'])
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
    if("llvm" IN_LIST FEATURES)
        set(MESA_ANDROID_GALLIUM_DRIVER llvmpipe)
    else()
        set(MESA_ANDROID_GALLIUM_DRIVER softpipe)
    endif()
    list(APPEND MESA_OPTIONS
        -Dplatforms=['android']
        -Dandroid-stub=true
        "-Dgallium-drivers=['${MESA_ANDROID_GALLIUM_DRIVER}']"
    )
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

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/docs/license.rst"
        "${SOURCE_PATH}/licenses/Apache-2.0"
        "${SOURCE_PATH}/licenses/BSL-1.0"
        "${SOURCE_PATH}/licenses/MIT"
        "${SOURCE_PATH}/licenses/SGI-B-2.0"
)
