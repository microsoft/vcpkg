vcpkg_list(SET patches)
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_list(SET patches
        yasm.patch # the asm changes are a downgrade to an older version
        compile.patch
        libname-windows.patch # Apply common libtool rules for lib naming. 
    )
endif()

vcpkg_from_gitlab(
    GITLAB_URL https://git.lysator.liu.se/
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nettle/nettle
    REF 52bacacaf4339fd78289f58919732f1f35bea1c1 #v3.7.3
    SHA512 0130d14195274eeec11e8299793e3037f4b84d8fb4b5c5c9392b63ee693ed5713434070744b1a44e14a6a5090d655917c1dd296e2011cd99e3c316ef5d8ee395
    HEAD_REF master
    PATCHES 
        fix-InstallLibPath.patch
        flags.patch
        ${patches}
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_list(SET OPTIONS --disable-static)
else()
    vcpkg_list(SET OPTIONS --disable-shared)
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
endif()

if(VCPKG_CROSSCOMPILING)
    # Silly trick to make configure accept CC_FOR_BUILD but in reallity CC_FOR_BUILD is deactivated. 
    set(ENV{CC_FOR_BUILD} "touch a.out | touch conftest${VCPKG_HOST_EXECUTABLE_SUFFIX} | true")
endif()

vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS
        --disable-documentation
        --disable-openssl
        ${OPTIONS}
)

set(tool_names des ecc) # aes gcm sha twofish?
list(TRANSFORM tool_names APPEND "data")
list(TRANSFORM tool_names APPEND "${VCPKG_HOST_EXECUTABLE_SUFFIX}")

if(VCPKG_CROSSCOMPILING)
    list(TRANSFORM tool_names PREPEND "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/${PORT}/")
    file(COPY ${tool_names} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    if(NOT VCPKG_BUILD_TYPE)
        file(COPY ${tool_names} DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/")
    endif()
endif()
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
    list(TRANSFORM tool_names PREPEND "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/")
    file(COPY ${tool_names} DESTINATION "${CURRENT_PACKAGES_DIR}/manual-tools/${PORT}")
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share/")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYINGv3"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR VCPKG_TARGET_IS_LINUX)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
