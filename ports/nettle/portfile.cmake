vcpkg_list(SET extra_patches)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND extra_patches
        libname-windows.patch # libtool rules for lib naming, exports
    )
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://git.lysator.liu.se/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nettle/nettle
    REF nettle_3.8.1_release_20220727
    SHA512 ed1fa1b77afd61fafa15b63f4324809fa69569691d16b93f403c83794672859a1760d102902349f93b1632de568c36e06a0e2b5b61877082b1982dfcf2c52172
    HEAD_REF master
    PATCHES 
        subdirs.patch
        fix-libdir.patch
        compile.patch
        host-tools.patch
        ccas.patch
        ${extra_patches}
)

vcpkg_cmake_get_vars(cmake_vars_file)
include("${cmake_vars_file}")

# Temporarily set to 1 to re-generate the lists of exported symbols.
# This is needed when the version is bumped.
set(GENERATE_SYMBOLS 0)
if(GENERATE_SYMBOLS)
    if(VCPKG_DETECTED_CMAKE_C_COMPILER_ID STREQUAL "MSVC")
        vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    else()
        set(GENERATE_SYMBOLS 0)
    endif()
endif()

vcpkg_list(SET OPTIONS)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_list(APPEND OPTIONS --disable-static)
else()
    vcpkg_list(APPEND OPTIONS --disable-shared)
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
    vcpkg_list(APPEND OPTIONS "CCAS=${ccas_command}" "ASMFLAGS=${asmflags}")
endif()

if(VCPKG_CROSSCOMPILING)
    set(ENV{HOST_TOOLS_PREFIX} "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}")
endif()

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    AUTOCONFIG
    OPTIONS
        ${OPTIONS}
        --disable-documentation
        --disable-openssl
        "gmp_cv_prog_exeext_for_build=${VCPKG_HOST_EXECUTABLE_SUFFIX}"
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        # def files are created by running 'llvm-nm <libname> | findstr /R /C:"[RT] _*nettle_"' on the static build and replacing '00[0-9abcdef]+ [RT]' with spaces
        # please update the defs if the version is bumped
        set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
        configure_file(
            "${CURRENT_PORT_DIR}/nettle-${VCPKG_TARGET_ARCHITECTURE}.def"
            "${build_dir}/nettle.def"
            COPYONLY
        )
        configure_file(
            "${CURRENT_PORT_DIR}/hogweed-${VCPKG_TARGET_ARCHITECTURE}.def"
            "${build_dir}/hogweed.def"
            COPYONLY
        )
        if(NOT VCPKG_BUILD_TYPE)
            set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
            configure_file(
                "${CURRENT_PORT_DIR}/nettle-${VCPKG_TARGET_ARCHITECTURE}.def" 
                "${build_dir}/nettle.def"
                COPYONLY
            )
            configure_file("${CURRENT_PORT_DIR}/hogweed-${VCPKG_TARGET_ARCHITECTURE}.def" 
                "${build_dir}/hogweed.def"
                COPYONLY
            )
        endif()
    endif()
endif()
vcpkg_install_make()

if(NOT VCPKG_CROSSCOMPILING)
    set(tool_names desdata eccdata) # aes gcm sha twofish?
    list(TRANSFORM tool_names PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    list(TRANSFORM tool_names APPEND "${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    file(COPY ${tool_names} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYINGv3")

if(GENERATE_SYMBOLS)
    include("${CMAKE_CURRENT_LIST_DIR}/lib-to-def.cmake")
    lib_to_def(BASENAME nettle REGEX "_*nettle_")
    lib_to_def(BASENAME hogweed REGEX "_*nettle_")
endif()
