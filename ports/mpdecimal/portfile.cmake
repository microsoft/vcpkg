vcpkg_download_distfile(ARCHIVE
    URLS "https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-${VERSION}.tar.gz"
    FILENAME "mpdecimal-${VERSION}.tar.gz"
    SHA512 431fa8ab90d6b8cdecc38b1618fd89d040185dec3c1150203e20f40f10a16160058f6b8abddd000f6ecb74f4dc42d9fef8111444f1496ab34c34f6b814ed32b7
)
vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES msvc-linkage.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(machine x64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(machine ppro)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(machine ansi64)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(machine ansi32)
    else()
        message(FATAL_ERROR "Unsupported MSVC architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(build_target "libmpdec-${VERSION}.dll")
        set(library_name "${build_target}.lib")
        set(dll_import 1)
    else()
        set(build_target "libmpdec-${VERSION}.lib")
        set(library_name "${build_target}")
        set(dll_import 0)
    endif()

    # vcpkg_build_nmake supplies the triplet's CRT and compiler flags via _CL_.
    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH libmpdec
        PROJECT_NAME Makefile.vc
        CL_LANGUAGE C
        TARGET "${build_target}"
        PRERUN_SHELL "${CMAKE_COMMAND}" -E touch Makefile
        OPTIONS "MACHINE=${machine}"
        OPTIONS_DEBUG "DEBUG=1"
    )

    foreach(config IN ITEMS release debug)
        if(DEFINED VCPKG_BUILD_TYPE AND NOT VCPKG_BUILD_TYPE STREQUAL config)
            continue()
        endif()
        if(config STREQUAL "release")
            set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec")
            set(destination "${CURRENT_PACKAGES_DIR}")
        else()
            set(build_dir "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec")
            set(destination "${CURRENT_PACKAGES_DIR}/debug")
        endif()
        file(INSTALL "${build_dir}/${library_name}" DESTINATION "${destination}/lib" RENAME libmpdec.lib)
        if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
            file(INSTALL "${build_dir}/${build_target}" DESTINATION "${destination}/bin")
        endif()
        file(INSTALL "${build_dir}/mpdecimal.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
        file(MAKE_DIRECTORY "${destination}/lib/pkgconfig")
        configure_file("${CURRENT_PORT_DIR}/libmpdec.pc.in" "${destination}/lib/pkgconfig/libmpdec.pc" @ONLY)
    endforeach()
    # DLL imports depend on library linkage, independently of the selected CRT.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mpdecimal.h"
        "defined(MPDECIMAL_DLL)" "${dll_import}")
    vcpkg_copy_pdbs()
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS --disable-cxx --disable-doc
    )
    vcpkg_make_install(TARGETS install)
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
