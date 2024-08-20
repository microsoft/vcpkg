vcpkg_from_gitlab(
    GITLAB_URL https://git.lysator.liu.se/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nettle/nettle
    REF nettle_3.10_release_20240616
    SHA512 8767e4f0c34ce76ead5d66f06f97e6b184d439fa94f848ee440196fafde3da2ea7cfc54f9bd8f9ab6a99929b0d14b3d5a28857e05d954551e94b619598c17659
    HEAD_REF master
    PATCHES 
        subdirs.patch
        fix-libdir.patch
        compile.patch
        host-tools.patch
        ccas.patch
        msvc-support.patch
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

# Maintainer switch: Temporarily set this to 1 to re-generate the lists
# of exported symbols. This is needed when the version is bumped.
set(GENERATE_SYMBOLS 0)
if(GENERATE_SYMBOLS)
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    else()
        set(GENERATE_SYMBOLS 0)
    endif()
endif()

vcpkg_list(SET OPTIONS)
if("tools" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --enable-tools)
endif()

# As in gmp
set(disable_assembly OFF)
set(ccas "")
set(asmflags "")
if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
    vcpkg_list(APPEND OPTIONS ac_cv_func_memset=yes)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        string(APPEND asmflags " --target=i686-pc-windows-msvc -m32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        string(APPEND asmflags " --target=x86_64-pc-windows-msvc")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        string(APPEND asmflags " --target=arm64-pc-windows-msvc")
    else()
        set(disable_assembly ON)
    endif()
    if(NOT disable_assembly)
        vcpkg_find_acquire_program(CLANG)
        set(ccas "${CLANG}")
    endif()
else()
    set(ccas "${VCPKG_DETECTED_CMAKE_C_COMPILER}")
endif()

if(disable_assembly)
    vcpkg_list(APPEND OPTIONS "--enable-assembler=no")
elseif(ccas)
    cmake_path(GET ccas PARENT_PATH ccas_dir)
    vcpkg_add_to_path("${ccas_dir}")
    cmake_path(GET ccas FILENAME ccas_command)
    vcpkg_list(APPEND OPTIONS "CCAS=${ccas_command}" "ASM_FLAGS=${asmflags}")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(GLOB def_files "${CMAKE_CURRENT_LIST_DIR}/*.def")
    file(COPY ${def_files} DESTINATION "${SOURCE_PATH}")
    vcpkg_list(APPEND OPTIONS "MSVC_TARGET=${VCPKG_TARGET_ARCHITECTURE}")
else()
    vcpkg_list(APPEND OPTIONS "MSVC_TARGET=no")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --disable-documentation
        --disable-openssl
        "gmp_cv_prog_exeext_for_build=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
    OPTIONS_DEBUG
        --disable-tools
)
vcpkg_install_make()
vcpkg_fixup_pkgconfig()

if(NOT VCPKG_CROSSCOMPILING)
    set(tool_names desdata eccdata) # aes gcm sha twofish?
    list(TRANSFORM tool_names PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    list(TRANSFORM tool_names APPEND "${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(COPY ${tool_names} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYINGv3")

if(GENERATE_SYMBOLS)
    include("${CMAKE_CURRENT_LIST_DIR}/lib-to-def.cmake")
    lib_to_def(BASENAME nettle REGEX "_*nettle_")
    lib_to_def(BASENAME hogweed REGEX "_*nettle_")
endif()
