if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(PATCHES windows.patch windows2.patch win_random.patch)
endif()

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xorg/xserver
    REF  6b997fb74e5c9473ee3989fca8d592a3a0d16067
    SHA512 c7b0cd797658e5582ec08698231f5c71368b5726e8d623f72ce3821c5e9cb18991c09cee59dd2f55a56f35599613fa800376c030cb60b159781ad78a63b89bf2
    HEAD_REF master # branch name
    PATCHES ${PATCHES} 
            xcvt.patch
) 
#https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config
set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")
file(TO_NATIVE_PATH "${PYTHON3}" PYTHON3_NATIVE)
set(ENV{PYTHON3} "${PYTHON3_NATIVE}")

vcpkg_add_to_path("${PYTHON3_DIR}/Scripts")

set(PYTHON_OPTION "--user")
if(NOT EXISTS ${PYTHON3_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX})
    if(NOT EXISTS ${PYTHON3_DIR}/Scripts/pip${VCPKG_HOST_EXECUTABLE_SUFFIX})
        vcpkg_from_github(
            OUT_SOURCE_PATH PYFILE_PATH
            REPO pypa/get-pip
            REF 309a56c5fd94bd1134053a541cb4657a4e47e09d #2019-08-25
            SHA512 bb4b0745998a3205cd0f0963c04fb45f4614ba3b6fcbe97efe8f8614192f244b7ae62705483a5305943d6c8fedeca53b2e9905aed918d2c6106f8a9680184c7a
            HEAD_REF master
        )
        execute_process(COMMAND ${PYTHON3_DIR}/python${VCPKG_HOST_EXECUTABLE_SUFFIX} ${PYFILE_PATH}/get-pip.py ${PYTHON_OPTION})
    endif()
    execute_process(COMMAND ${PYTHON3_DIR}/easy_install${VCPKG_HOST_EXECUTABLE_SUFFIX} lxml)
endif()

vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${FLEX_DIR}")
vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_DIR "${BISON}" DIRECTORY )
vcpkg_add_to_path(PREPEND "${BISON_DIR}")

if(WIN32) # WIN32 HOST probably has win_flex and win_bison!
    if(NOT EXISTS "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${FLEX}" "${FLEX_DIR}/flex${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
    if(NOT EXISTS "${BISON_DIR}/BISON${VCPKG_HOST_EXECUTABLE_SUFFIX}")
        file(CREATE_LINK "${BISON}" "${BISON_DIR}/bison${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    endif()
endif()
#xvfb
if("xwayland" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxwayland=true)
else()
    list(APPEND OPTIONS -Dxwayland=false)
endif()
if("xnest" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxnest=true)
else()
    list(APPEND OPTIONS -Dxnest=false)
endif()
if("xephyr" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxephyr=true)
else()
    list(APPEND OPTIONS -Dxephyr=false)
endif()
if("xorg" IN_LIST FEATURES)
    list(APPEND OPTIONS -Dxorg=true)
else()
    list(APPEND OPTIONS -Dxorg=false)
endif()
if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -Dglx=false) #Requires Mesa3D for gl.pc
    list(APPEND OPTIONS -Dsecure-rpc=false) #Problem encountered: secure-rpc requested, but neither libtirpc or libc RPC support were found
    list(APPEND OPTIONS -Dlisten_tcp=true)
    list(APPEND OPTIONS -Dlisten_local=false)
    list(APPEND OPTIONS -Dxwin=true)
    set(ENV{INCLUDE} "$ENV{INCLUDE};${CURRENT_INSTALLED_DIR}/include")
else()
    if("xwin" IN_LIST FEATURES)
        list(APPEND OPTIONS -Dxwin=true)
    else()
        list(APPEND OPTIONS -Dxwin=false)
    endif()
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${OPTIONS}
        -Dlisten_tcp=true
        -Ddocs=false
    OPTIONS_RELEASE
        -Dlog_dir=./logs/
        -Dxkb_dir=./../../share/xkbcomp/X11/xkb
        -Dxkb_output_dir=./xkb/out/
        -Dxkb_bin_dir=./../xkbcomp/
    OPTIONS_DEBUG
        -Dlog_dir=./logs/
        -Dxkb_dir=./../../../share/xkbcomp/X11/xkb
        -Dxkb_output_dir=./xkb/out/
        -Dxkb_bin_dir=./../../xkbcomp/
)
# Seems like the xkb option don't really help. Manual moving of the xkb folder needed. 
vcpkg_install_meson()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/var" "${CURRENT_PACKAGES_DIR}/var")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")
set(TOOLS cvt gtf Xorg Xvfb Xwayland Xwin Xming xwinclip)
foreach(_tool ${TOOLS})
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${_tool}.pdb" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/${_tool}.pdb")
        endif()
    endif()
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        if(VCPKG_TARGET_IS_WINDOWS)
            file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}.pdb" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/${_tool}.pdb")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/debug/bin/${_tool}.pdb")
        endif()
    endif()
endforeach()

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/xserver")

file(GLOB_RECURSE BIN_FILES "${CURRENT_PACKAGES_DIR}/bin")
if(NOT BIN_FILES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()