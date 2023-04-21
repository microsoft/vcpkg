vcpkg_list(SET extra_patches)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(APPEND extra_patches
        yasm.patch # the asm changes are a downgrade to an older version
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
        install-dll.patch
        ${extra_patches}
)

# Temporarily set to 1 to re-generate the lists of exported symbols.
# This is needed when the version is bumped.
set(GENERATE_SYMBOLS 0)
if(GENERATE_SYMBOLS)
    if(VCPKG_TARGET_IS_MINGW OR NOT VCPKG_TARGET_IS_WINDOWS)
        set(GENERATE_SYMBOLS 0)
    else()
        vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    endif()
endif()

vcpkg_list(SET OPTIONS)
if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_list(APPEND OPTIONS --disable-static)
else()
    vcpkg_list(APPEND OPTIONS --disable-shared)
endif()

if("tools" IN_LIST FEATURES)
    vcpkg_list(APPEND OPTIONS --enable-tools)
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(ENV{CCAS} "${CURRENT_HOST_INSTALLED_DIR}/tools/yasm/yasm${VCPKG_HOST_EXECUTABLE_SUFFIX}")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(asmflag win64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(asmflag win32)
    endif()
    set(ENV{ASMFLAGS} "-Xvc -f ${asmflag} -pgas -rraw")
    vcpkg_list(APPEND OPTIONS
        ac_cv_func_memset=yes
        nettle_cv_asm_type_percent_function=no
        nettle_cv_asm_align_log=no
    )
else()
    vcpkg_list(APPEND OPTIONS "CCAS=") # configure will use CC
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
    OPTIONS_DEBUG
        --disable-tools
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

vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug")

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
