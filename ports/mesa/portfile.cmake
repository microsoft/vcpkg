# Build-Depends: From X Window PR: zstd, drm (!windows), elfutils (!windows), wayland (!windows), wayland-protocols (!windows), xdamage, xshmfence (!windows), x11, xcb, xfixes, xext, xxf86vm, xrandr, xv, xvmc (!windows), egl-registry, opengl-registry, tool-meson
# Required LLVM modules: LLVM (modules: bitwriter, core, coroutines, engine, executionengine, instcombine, mcdisassembler, mcjit, scalaropts, transformutils) found: YES 

# Patches are from https://github.com/pal1000/mesa-dist-win/tree/master/patches
set(PATCHES
    # Fix swrAVX512 build
    swravx512-post-static-link.patch
)

vcpkg_check_linkage(ONLY_DYNAMIC_CRT)
if(VCPKG_TARGET_IS_WINDOWS)
    set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled) # some parts of this port can only build as a shared library.
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mesa/mesa
    REF mesa-21.2.0
    SHA512 4837e42474d69861fbce4fa03d120b56997094d61b3045c417bbab73774dda86e4b7adf54af98585511a3517860c33c77898e6171cd845f760bada4b000ff52d
    HEAD_REF master
    PATCHES ${PATCHES}
) 
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
vcpkg_add_to_path("${PYTHON3_DIR}/Scripts")
set(ENV{PYTHON} "${PYTHON3}")

function(vcpkg_get_python_package PYTHON_DIR )
    cmake_parse_arguments(PARSE_ARGV 0 _vgpp "" "PYTHON_EXECUTABLE" "PACKAGES")
    
    if(NOT _vgpp_PYTHON_EXECUTABLE)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PYTHON_EXECUTABLE!")
    endif()
    if(NOT _vgpp_PACKAGES)
        message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION} requires parameter PACKAGES!")
    endif()
    if(NOT _vgpp_PYTHON_DIR)
        get_filename_component(_vgpp_PYTHON_DIR "${_vgpp_PYTHON_EXECUTABLE}" DIRECTORY)
    endif()

    if (WIN32)
        set(PYTHON_OPTION "")
    else()
        set(PYTHON_OPTION "--user")
    endif()

    if("${_vgpp_PYTHON_DIR}" MATCHES "${DOWNLOADS}") # inside vcpkg
        if(NOT EXISTS "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}")
            if(NOT EXISTS "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}")
                vcpkg_from_github(
                    OUT_SOURCE_PATH PYFILE_PATH
                    REPO pypa/get-pip
                    REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
                    SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
                    HEAD_REF master
                )
                execute_process(COMMAND "${_vgpp_PYTHON_EXECUTABLE}" "${PYFILE_PATH}/get-pip.py" ${PYTHON_OPTION})
            endif()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX}" install ${_package} ${PYTHON_OPTION})
            endforeach()
        else()
            foreach(_package IN LISTS _vgpp_PACKAGES)
                execute_process(COMMAND "${_vgpp_PYTHON_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX}" ${_package})
            endforeach()
        endif()
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            execute_process(COMMAND pip3 install ${_vgpp_PACKAGES})
        endif()
    else() # outside vcpkg
        foreach(_package IN LISTS _vgpp_PACKAGES)
            execute_process(COMMAND ${_vgpp_PYTHON_EXECUTABLE} -c "import ${_package}" RESULT_VARIABLE HAS_ERROR)
            if(HAS_ERROR)
                message(FATAL_ERROR "Python package '${_package}' needs to be installed for port '${PORT}'.\nComplete list of required python packages: ${_vgpp_PACKAGES}")
            endif()
        endforeach()
    endif()
endfunction()

vcpkg_get_python_package(PYTHON_EXECUTABLE "${PYTHON3}" PACKAGES setuptools mako)

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
#string(APPEND GALLIUM_DRIVERS 'auto')
list(APPEND MESA_OPTIONS -Dzstd=enabled)
list(APPEND MESA_OPTIONS -Dshared-llvm=auto)
list(APPEND MESA_OPTIONS -Dlibunwind=disabled)
list(APPEND MESA_OPTIONS -Dlmsensors=disabled)
list(APPEND MESA_OPTIONS -Dvalgrind=disabled)
list(APPEND MESA_OPTIONS -Dglvnd=false)
list(APPEND MESA_OPTIONS -Dglx=disabled)
list(APPEND MESA_OPTIONS -Dgbm=disabled)
list(APPEND MESA_OPTIONS -Dosmesa=true)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND MESA_OPTIONS -Dshared-swr=false)
    list(APPEND MESA_OPTIONS "-Dswr-arches=['avx']")
else()
    list(APPEND MESA_OPTIONS -Dshared-swr=true)
    list(APPEND MESA_OPTIONS "-Dswr-arches=['avx','avx2','knl','skx']")
endif()

string(APPEND GALLIUM_DRIVERS 'swrast')
if("llvm" IN_LIST FEATURES)
    list(APPEND MESA_OPTIONS -Dllvm=enabled)
    string(APPEND GALLIUM_DRIVERS ",'swr'") # SWR always requires llvm
else()
    list(APPEND MESA_OPTIONS -Dllvm=disabled)
endif()

list(APPEND MESA_OPTIONS -Dgallium-drivers=[${GALLIUM_DRIVERS}])

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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

#installed by egl-registry
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/egl.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/eglext.h)
file(REMOVE ${CURRENT_PACKAGES_DIR}/include/EGL/eglplatform.h)
#installed by opengl-registry
set(_double_files include/GL/glcorearb.h include/GL/glext.h include/GL/glxext.h 
    include/GLES/egl.h include/GLES/gl.h include/GLES/glext.h include/GLES/glplatform.h 
    include/GLES2/gl2.h include/GLES2/gl2ext.h include/GLES2/gl2platform.h
    include/GLES3/gl3.h  include/GLES3/gl31.h include/GLES3/gl32.h include/GLES3/gl3platform.h)
list(TRANSFORM _double_files PREPEND "${CURRENT_PACKAGES_DIR}/")
file(REMOVE ${_double_files})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/GLES)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/GLES2)
# # Handle copyright
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(TOUCH "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright")
