# Build-Depends: From X Window PR: zstd, drm (!windows), elfutils (!windows), wayland (!windows), wayland-protocols (!windows), xdamage, xshmfence (!windows), x11, xcb, xfixes, xext, xxf86vm, xrandr, xv, xvmc (!windows), egl-registry, opengl-registry, tool-meson
# Required LLVM modules: LLVM (modules: bitwriter, core, coroutines, engine, executionengine, instcombine, mcdisassembler, mcjit, scalaropts, transformutils) found: YES 

# Patches are from https://github.com/pal1000/mesa-dist-win/tree/master/patches
set(PATCHES
    # Fix symbols exporting for MinGW GCC x86
    def-fixes.patch
    # Fix MinGW clang build
    clang.patch
    # Clover build on Windows
    clover.patch
)

vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # some parts of this port can only build as a shared library.
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF mesa-22.0.2
    SHA512 1139bae1fa9f9b49727c5aaddad9b2908c7643d7c6c435544e8322c84d17c012f04aa73876bef8cab9b517e36957eb2a678b3001da2d69a32497ef4569f6172e
    FILE_DISAMBIGUATOR 1
    HEAD_REF master
    PATCHES ${PATCHES}
) 


x_vcpkg_get_python_packages(PYTHON_VERSION "3" OUT_PYTHON_VAR "PYTHON3" PACKAGES setuptools mako )

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
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

# For features https://github.com/pal1000/mesa-dist-win should be probably studied a bit more. 
list(APPEND MESA_OPTIONS -Dzstd=enabled)
list(APPEND MESA_OPTIONS -Dshared-llvm=auto)
list(APPEND MESA_OPTIONS -Dlibunwind=disabled)
list(APPEND MESA_OPTIONS -Dlmsensors=disabled)
list(APPEND MESA_OPTIONS -Dvalgrind=disabled)
list(APPEND MESA_OPTIONS -Dglvnd=false)
list(APPEND MESA_OPTIONS -Dglx=disabled)
list(APPEND MESA_OPTIONS -Dgbm=disabled)
list(APPEND MESA_OPTIONS -Dosmesa=true)

if("llvm" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dllvm=enabled)
else()
    list(APPEND MESA_OPTIONS -Dllvm=disabled)
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
if("opengl" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dopengl=true)
else()
    list(APPEND MESA_OPTIONS -Dopengl=false)
endif()
if("egl" IN_LIST FEATURES) # EGL feature only works on Linux
    list(APPEND MESA_OPTIONS -Degl=enabled)
else()
    list(APPEND MESA_OPTIONS -Degl=disabled)
endif()

list(APPEND MESA_OPTIONS -Dshared-glapi=enabled)  #shared GLAPI required when building two or more of the following APIs - opengl, gles1 gles2

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MESA_OPTIONS -Dplatforms=['windows'])
    list(APPEND MESA_OPTIONS -Dmicrosoft-clc=disabled)
    if(NOT VCPKG_TARGET_IS_MINGW)
        set(VCPKG_CXX_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_CXX_FLAGS}")
        set(VCPKG_C_FLAGS "/D_CRT_DECLARE_NONSTDC_NAMES ${VCPKG_C_FLAGS}")
    endif()
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -Dgles-lib-suffix=_mesa
        #-D egl-lib-suffix=_mesa
        -Dbuild-tests=false
        ${MESA_OPTIONS}
    )
vcpkg_install_meson()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

#installed by egl-registry
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/KHR")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/EGL/egl.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/EGL/eglext.h")
file(REMOVE "${CURRENT_PACKAGES_DIR}/include/EGL/eglplatform.h")
#installed by opengl-registry
set(_double_files include/GL/glcorearb.h include/GL/glext.h include/GL/glxext.h 
    include/GLES/egl.h include/GLES/gl.h include/GLES/glext.h include/GLES/glplatform.h 
    include/GLES2/gl2.h include/GLES2/gl2ext.h include/GLES2/gl2platform.h
    include/GLES3/gl3.h  include/GLES3/gl31.h include/GLES3/gl32.h include/GLES3/gl3platform.h)
list(TRANSFORM _double_files PREPEND "${CURRENT_PACKAGES_DIR}/")
file(REMOVE ${_double_files})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/GLES")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/GLES2")
# Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
