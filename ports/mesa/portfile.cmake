vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # some parts of this port can only build as a shared library.
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF mesa-${VERSION}
    SHA512 202b2b20ffe7d357570a0d0bf0b53dc246b3e903738e8c8a000c5f61109ab5233d62de217444f49fd62927f8c418d929e5a2a5a800d1e39e334d50eb090e850c
    PATCHES
        dependencies.diff
        python.diff
        winflex-race.diff
)

x_vcpkg_get_python_packages(PYTHON_VERSION "3" OUT_PYTHON_VAR "PYTHON3" PACKAGES setuptools mako)

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
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

if("offscreen" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dosmesa=true)
else()
    list(APPEND MESA_OPTIONS -Dosmesa=false)
endif()

if("llvm" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dllvm=enabled)
else()
    list(APPEND MESA_OPTIONS -Dllvm=disabled)
endif()

if("opengl" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dopengl=true)
else()
    list(APPEND MESA_OPTIONS -Dopengl=false)
endif()

set(shared_glapi auto)
# meson_build: disable_auto_if(host_machine.system() == 'windows')
if(VCPKG_TARGET_IS_WINDOWS)
    set(shared_glapi disabled)
endif()
if("gles1" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dgles1=enabled)
    set(shared_glapi enabled)
else()
    list(APPEND MESA_OPTIONS -Dgles1=disabled)
endif()
if("gles2" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dgles2=enabled)
    set(shared_glapi enabled)
else()
    list(APPEND MESA_OPTIONS -Dgles2=disabled)
endif()
if("egl" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Degl=enabled)
    set(shared_glapi enabled)
else()
    list(APPEND MESA_OPTIONS -Degl=disabled)
endif()
list(APPEND MESA_OPTIONS -Dshared-glapi=${shared_glapi})

if(NOT "vulkan" IN_LIST FEATURES) # EGL feature only works on Linux
    list(APPEND MESA_OPTIONS -Dvulkan-drivers=[])
elseif(EXISTS "${CURRENT_HOST_INSTALLED_DIR}/tools/glslang")
    vcpkg_list(APPEND MESA_ADDITIONAL_BINARIES "glslangValidator = '${CURRENT_HOST_INSTALLED_DIR}/tools/glslang/glslangValidator${VCPKG_HOST_EXECUTABLE_SUFFIX}'")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MESA_OPTIONS -Dplatforms=['windows'])
    list(APPEND MESA_OPTIONS -Dmicrosoft-clc=disabled)
    if(NOT VCPKG_TARGET_IS_MINGW)
        set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
        set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
    endif()
elseif(VCPKG_TARGET_IS_ANDROID)
    list(APPEND MESA_OPTIONS -Dplatforms=['android'])
elseif("wayland" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dplatforms=['x11','wayland'])
else()
    list(APPEND MESA_OPTIONS -Dplatforms=['x11'])
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dbuild-tests=false
        -Dcpp_rtti=true
        -Degl-lib-suffix=_mesa
        -Dexpat=disabled
        -Dgles-lib-suffix=_mesa
        -Dlibunwind=disabled
        -Dshared-llvm=disabled  # disable autodetection - fails; llvm is ONLY_STATIC_LIBRARY
        -Dvalgrind=disabled
        -Dzstd=enabled
        ${MESA_OPTIONS}
    ADDITIONAL_BINARIES
        python=['${PYTHON3}','-I']
        python3=['${PYTHON3}','-I']
        ${MESA_ADDITIONAL_BINARIES}
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

if(VCPKG_TARGET_IS_WINDOWS AND "opengl" IN_LIST FEATURES)
    # opengl32.lib is already installed by port opengl.
    # Mesa claims to provide a drop-in replacement of opengl32.dll.
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/opengl32.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/opengl32.lib")
    if(NOT VCPKG_BUILD_TYPE)
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/opengl32.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/opengl32.lib")
    endif()
endif()

if(VCPKG_TARGET_IS_WINDOWS and "egl" IN_LIST FEATURES)
    # egl.pc is owned by port egl. Override that port to make egl.pc require egl_mesa instead of egl from angle.
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/egl.pc" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/egl_mesa.pc")
    if(NOT VCPKG_BUILD_TYPE)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/egl.pc" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/egl_mesa.pc")
    endif()
endif()

if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/docs/license.rst")
