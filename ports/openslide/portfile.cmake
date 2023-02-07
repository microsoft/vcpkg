vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
  set(PATCHES fix-win-build.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO openslide/openslide
    REF "v${VERSION}" 
    SHA512 1b6bc4722fd6901d7c929ec332177d4892ea15700133c1a1339c6bdcace174064b5e063d3bcb2044e2ca56801c044f7b3d1c774c0b29f9005361a8336e297e4b
    HEAD_REF master
    PATCHES remove-w-flags.patch
            ${PATCHES}
)

set(opts "")
if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND opts "ac_cv_search_floor=none required")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    #switching to clang-cl due to __attribute__((constructor)) in openslide.c
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
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS ${opts}
)

vcpkg_install_make()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
