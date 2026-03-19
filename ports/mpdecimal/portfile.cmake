vcpkg_download_distfile(ARCHIVE
    URLS "https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-${VERSION}.tar.gz"
    FILENAME "mpdecimal-${VERSION}.tar.gz"
    SHA512 431fa8ab90d6b8cdecc38b1618fd89d040185dec3c1150203e20f40f10a16160058f6b8abddd000f6ecb74f4dc42d9fef8111444f1496ab34c34f6b814ed32b7
)

vcpkg_extract_source_archive(SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES msvc-crt.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(NMAKE_MACHINE "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(NMAKE_MACHINE "ansi64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(NMAKE_MACHINE "ansi32")
    else()
        set(NMAKE_MACHINE "ppro")
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(CRT_REL "/MT")
        set(CRT_DBG "/MTd")
    else()
        set(CRT_REL "/MD")
        set(CRT_DBG "/MDd")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(BUILD_TARGET "libmpdec-${VERSION}.dll")
        set(LIB_NAME "libmpdec-${VERSION}.dll.lib")
        set(DLL_NAME "libmpdec-${VERSION}.dll")
        set(INSTALL_DLL ON)
    else()
        set(BUILD_TARGET "libmpdec-${VERSION}.lib")
        set(LIB_NAME "libmpdec-${VERSION}.lib")
        set(INSTALL_DLL OFF)
    endif()

    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "libmpdec"
        PROJECT_NAME "Makefile.vc"
        CL_LANGUAGE C
        TARGET "${BUILD_TARGET}"
        PRERUN_SHELL "${CMAKE_COMMAND}" -E touch Makefile
        OPTIONS
            "MACHINE=${NMAKE_MACHINE}"
        OPTIONS_RELEASE
            "OPT=${CRT_REL} /O2 /GS /EHsc /DNDEBUG"
            "OPT_SHARED=${CRT_REL} /O2 /GS /EHsc /DNDEBUG"
        OPTIONS_DEBUG
            "OPT=${CRT_DBG} /Od /Zi /EHsc"
            "OPT_SHARED=${CRT_DBG} /Od /Zi /EHsc"
            "DEBUG=1"
    )

    set(LIBMPDEC_REL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec")
    set(LIBMPDEC_DBG "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec")

    # Install header (generated during release build)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY "${LIBMPDEC_REL}/mpdecimal.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    endif()

    # Install release library
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY "${LIBMPDEC_REL}/${LIB_NAME}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}" "${CURRENT_PACKAGES_DIR}/lib/mpdec.lib")
        if(INSTALL_DLL)
            file(COPY "${LIBMPDEC_REL}/${DLL_NAME}" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        endif()
    endif()

    # Install debug library
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY "${LIBMPDEC_DBG}/${LIB_NAME}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/${LIB_NAME}" "${CURRENT_PACKAGES_DIR}/debug/lib/mpdec.lib")
        if(INSTALL_DLL)
            file(COPY "${LIBMPDEC_DBG}/${DLL_NAME}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    endif()
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            "--disable-cxx"
    )
    vcpkg_make_install(TARGETS install)
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/share"
        "${CURRENT_PACKAGES_DIR}/debug/share"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
