vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://code.videolan.org/videolan/libplacebo.git
    REF 3188549fba13bbdf3a5a98de2a38c2e71f04e21e
    HEAD_REF master
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/fix-glslang-spirv.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-pkgconfig-cxx.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-python-3.14.patch" # cherry picked from upstream, remove in next version update
        "${CMAKE_CURRENT_LIST_DIR}/fix-spirv-cross.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-vulkan.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-win-shlwapi.patch"
)

set (JINJA_VERSION "3.1.6")
set (MARKUPSAFE_VERSION "3.0.2")
set (GLAD2_VERSION "2.0.8")

# Find python3 for meson
vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
vcpkg_add_to_path("${PYTHON3_DIR}")

x_vcpkg_get_python_packages(OUT_PYTHON_VAR PYTHON3 PYTHON_VERSION "3" PACKAGES jinja2==${JINJA_VERSION} markupsafe==${MARKUPSAFE_VERSION} glad2==${GLAD2_VERSION})

# Build meson options list
set(MESON_OPTIONS
    -Ddemos=false
    -Dtests=false
    -Dbench=false
    -Dfuzz=false
    -Ddebug-abort=false
    -Dvk-proc-addr=disabled
)

# Set prefer_static when building static libraries to help Meson find static libs
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    list(APPEND MESON_OPTIONS -Dprefer_static=true)
endif()

# Handle optional features (Meson uses 'enabled', 'disabled', or 'auto')
if("vulkan" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dvulkan=enabled)
    # Point to vcpkg-installed Vulkan registry
    set(VULKAN_REGISTRY "${CURRENT_INSTALLED_DIR}/share/vulkan/registry/vk.xml")
    # check if the file exists
    message(STATUS "Checking if Vulkan registry exists at ${VULKAN_REGISTRY}")
    if(EXISTS "${VULKAN_REGISTRY}")
        list(APPEND MESON_OPTIONS -Dvulkan-registry=${VULKAN_REGISTRY})
    else()
        message(FATAL_ERROR "Vulkan registry not found at ${VULKAN_REGISTRY}")
    endif()
else()
    list(APPEND MESON_OPTIONS -Dvulkan=disabled)
endif()

if("opengl" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dopengl=enabled)
else()
    list(APPEND MESON_OPTIONS -Dopengl=disabled)
endif()

if("d3d11" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dd3d11=enabled)
else()
    list(APPEND MESON_OPTIONS -Dd3d11=disabled)
endif()

if("glslang" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dglslang=enabled)
else()
    list(APPEND MESON_OPTIONS -Dglslang=disabled)
endif()

if("shaderc" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dshaderc=enabled)
else()
    list(APPEND MESON_OPTIONS -Dshaderc=disabled)
endif()

if("lcms" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dlcms=enabled)
else()
    list(APPEND MESON_OPTIONS -Dlcms=disabled)
endif()

if("xxhash" IN_LIST FEATURES)
    list(APPEND MESON_OPTIONS -Dxxhash=enabled)
else()
    list(APPEND MESON_OPTIONS -Dxxhash=disabled)
endif()

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")
set(cxx_link_libraries "")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    block(PROPAGATE cxx_link_libraries)
        list(REMOVE_ITEM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES ${VCPKG_DETECTED_CMAKE_C_IMPLICIT_LINK_LIBRARIES})
        list(TRANSFORM VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES REPLACE "^([^/]+)\$" "'-l\\1'")
        string(JOIN ", " cxx_link_libraries ${VCPKG_DETECTED_CMAKE_CXX_IMPLICIT_LINK_LIBRARIES})
    endblock()
endif()
set(extra_libs "[ ${cxx_link_libraries} ]")

set(NO_STATIC_WINDOWS_LIBS false)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    # Searching for windows libraries when `prefer_static` is enabled is broken in Meson when using clang-cl, 
    # so we need to disable finding them and add them manually to the pkgconfig file
    if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(NO_STATIC_WINDOWS_LIBS true)
    endif()

    # libplacebo is not compatible with MSVC, use clang-cl
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        vcpkg_find_acquire_program(CLANG)
        cmake_path(GET CLANG PARENT_PATH CLANG_PARENT_PATH)
        set(CLANG_CL "${CLANG_PARENT_PATH}/clang-cl.exe")
        set(LLD_LINK "${CLANG_PARENT_PATH}/lld-link.exe")
        set(compiler_flags "")
        set(linker_flags "")
        if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            string(APPEND compiler_flags " --target=i686-pc-windows-msvc -m32")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            string(APPEND compiler_flags " --target=x86_64-pc-windows-msvc")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
            string(APPEND compiler_flags " --target=arm-pc-windows-msvc")
        elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
            string(APPEND compiler_flags " --target=arm64-pc-windows-msvc")
        endif()
        file(READ "${cmake_vars_file}" contents)
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_C_COMPILER \"${CLANG_CL}\")")
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_CXX_COMPILER \"${CLANG_CL}\")")
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_LINKER \"${LLD_LINK}\")")
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_C_FLAGS \"${VCPKG_DETECTED_CMAKE_C_FLAGS} ${compiler_flags}\")")
        string(APPEND contents "\nset(VCPKG_DETECTED_CMAKE_CXX_FLAGS \"${VCPKG_DETECTED_CMAKE_CXX_FLAGS} ${compiler_flags}\")")
        string(APPEND contents "\nset(VCPKG_COMBINED_C_FLAGS_DEBUG \"${VCPKG_COMBINED_C_FLAGS_DEBUG} ${compiler_flags}\")")
        string(APPEND contents "\nset(VCPKG_COMBINED_C_FLAGS_RELEASE \"${VCPKG_COMBINED_C_FLAGS_RELEASE} ${compiler_flags}\")")
        string(APPEND contents "\nset(VCPKG_COMBINED_CXX_FLAGS_DEBUG \"${VCPKG_COMBINED_CXX_FLAGS_DEBUG} ${compiler_flags}\")")
        string(APPEND contents "\nset(VCPKG_COMBINED_CXX_FLAGS_RELEASE \"${VCPKG_COMBINED_CXX_FLAGS_RELEASE} ${compiler_flags}\")")
        file(WRITE "${cmake_vars_file}" "${contents}")
    endif()
    set(cmake_vars_file "${cmake_vars_file}" CACHE INTERNAL "") # Don't run z_vcpkg_get_cmake_vars twice
endif()



# Set up meson
vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${MESON_OPTIONS}
    ADDITIONAL_PROPERTIES
        "vulkan_headers_inc = '${CURRENT_INSTALLED_DIR}/include'\nextra_libs = ${extra_libs}\nno_static_windows_libs = ${NO_STATIC_WINDOWS_LIBS}"
)

# Meson and/or Ninja is spuriously adding /MACHINE:arm to the ar flags in an non-configurable way, so we have to remove it manually
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/build.ninja" "/MACHINE:arm " "")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/build.ninja" "/MACHINE:arm " "")
    endif()
endif()

vcpkg_install_meson()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/meson-private/libplacebo.pc")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        if(NO_STATIC_WINDOWS_LIBS)
            if("d3d11" IN_LIST FEATURES)
                vcpkg_replace_string("${pkgconfig_file}" "spirv-cross-cpp.lib" "spirv-cross-cpp.lib -lversion")
            endif()
            vcpkg_replace_string("${pkgconfig_file}" "Libs: " "Libs: -lshlwapi ")
        else()
            vcpkg_replace_string("${pkgconfig_file}" "-lplacebo" "-llibplacebo")
        endif()
    endif()
    file(COPY "${pkgconfig_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib/pkgconfig")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    set(pkgconfig_file "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/meson-private/libplacebo.pc")
    if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
        if(NO_STATIC_WINDOWS_LIBS)
            if("d3d11" IN_LIST FEATURES)
                vcpkg_replace_string("${pkgconfig_file}" "spirv-cross-cppd.lib" "spirv-cross-cppd.lib -lversion")
            endif()
            vcpkg_replace_string("${pkgconfig_file}" "Libs: " "Libs: -lshlwapi ")
        else()
            vcpkg_replace_string("${pkgconfig_file}" "-lplacebo" "-llibplacebo")
        endif()
    endif()
    file(COPY "${pkgconfig_file}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig")
endif()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/LICENSE)

