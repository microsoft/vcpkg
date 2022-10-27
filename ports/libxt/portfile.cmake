if(NOT X_VCPKG_FORCE_VCPKG_X_LIBRARIES AND NOT VCPKG_TARGET_IS_WINDOWS)
    message(STATUS "Utils and libraries provided by '${PORT}' should be provided by your system! Install the required packages or force vcpkg libraries by setting X_VCPKG_FORCE_VCPKG_X_LIBRARIES in your triplet!")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    # Downstream uses &widgetClassRec in a const context which doesn't work 
    # if this is a dynamic library since the memory adress is only known at runtime
endif()

if(VCPKG_CROSSCOMPILING)
    set(PATCHES cc_for_build.patch)
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.freedesktop.org/xorg
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lib/libxt
    REF edd70bdfbbd16247e3d9564ca51d864f82626eb7 # 1.2.1
    SHA512  c49876253dfd187e7d56a098d3d992157daefa2c25ee732eaae5818ee04513bedd807d2f265085db2e82c0b1821e152a88fb4998c0002f6ac57204543fe18566
    HEAD_REF master
    PATCHES windows_build.patch
            globals.patch
            getcwd.patch
            ${PATCHES}
) 

set(ENV{ACLOCAL} "aclocal -I \"${CURRENT_INSTALLED_DIR}/share/xorg/aclocal/\"")

string(APPEND VCPKG_C_FLAGS " -DXT_BUILD")
string(APPEND VCPKG_CXX_FLAGS " -DXT_BUILD")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    string(APPEND VCPKG_C_FLAGS " -DXT_DLL_EXPORTS")
    string(APPEND VCPKG_CXX_FLAGS " -DXT_DLL_EXPORTS")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        vcpkg_find_acquire_program(CLANG)
        cmake_path(GET CLANG PARENT_PATH CLANG_PARENT_PATH)
        set(CLANG_CL "${CLANG_PARENT_PATH}/clang-cl.exe")
        file(READ "${cmake_vars_file}" contents)
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_C_COMPILER \"${CLANG_CL}\")")
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_CXX_COMPILER \"${CLANG_CL}\")")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
            string(APPEND contents "\nstring(APPEND VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG \" -m32\")")
            string(APPEND contents "\nstring(APPEND VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE \" -m32\")")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL arm64)
            string(APPEND contents "\nstring(PREPEND VCPKG_DETECTED_CMAKE_C_FLAGS_DEBUG \"--target=arm64-pc-win32 \")")
            string(APPEND contents "\nstring(PREPEND VCPKG_DETECTED_CMAKE_C_FLAGS_RELEASE \"--target=arm64-pc-win32 \")")
        endif()
        file(WRITE "${cmake_vars_file}" "${contents}")
    endif()
    set(cmake_vars_file "${cmake_vars_file}" CACHE INTERNAL "") # Don't run z_vcpkg_get_cmake_vars twice
    set(OPTIONS --disable-selective-werror)
endif()



vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS 
        --with-xfile-search-path=X11
        --with-appdefaultdir=share/X11/app-defaults
        --enable-malloc0returnsnull=yes
        xorg_cv_malloc0_returns_null=yes
        ${OPTIONS}
)

if(VCPKG_CROSSCOMPILING)
    file(INSTALL "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/makestrs${VCPKG_HOST_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/util/")
    if(NOT VCPKG_BUILD_TYPE)
        file(INSTALL "${CURRENT_HOST_INSTALLED_DIR}/tools/${PORT}/makestrs${VCPKG_HOST_EXECUTABLE_SUFFIX}" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/util/")
    endif()
endif()

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic" AND VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/StringDefs.h" "defined(XT_DLL_EXPORTS)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/Shell.h" "defined(XT_DLL_EXPORTS)" "1")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/Intrinsic.h" "defined(XT_DLL_EXPORTS)" "1")
    # XTSTRINGDEFINES is required since the "strings" are often used in a const context which doesn't work if they are adresses of a global array in another dll 
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/StringDefs.h" "#define _XtStringDefs_h_" "#define _XtStringDefs_h_\n#define XTSTRINGDEFINES")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/X11/Shell.h" "#define _XtShell_h" "#define _XtShell_h\n#define XTSTRINGDEFINES")
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/xt.pc" " -lXt" " -lXt -lws2_32")
    if(NOT VCPKG_BUILD_TYPE)
            vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/xt.pc" " -lXt" " -lXt -lws2_32")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT VCPKG_CROSSCOMPILING)
    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/util/makestrs${VCPKG_TARGET_EXECUTABLE_SUFFIX}" 
            DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
