vcpkg_download_distfile(ARCHIVE
    URLS "https://www.bytereef.org/software/mpdecimal/releases/mpdecimal-${VERSION}.tar.gz"
    FILENAME "mpdecimal-${VERSION}.tar.gz"
    SHA512 431fa8ab90d6b8cdecc38b1618fd89d040185dec3c1150203e20f40f10a16160058f6b8abddd000f6ecb74f4dc42d9fef8111444f1496ab34c34f6b814ed32b7
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES
        msvc-crt.patch
)

if(VCPKG_TARGET_IS_WINDOWS)
    file(COPY_FILE "${SOURCE_PATH}/libmpdec/makefile.vc" "${SOURCE_PATH}/libmpdec/Makefile")
    file(COPY_FILE "${SOURCE_PATH}/libmpdec++/makefile.vc" "${SOURCE_PATH}/libmpdec++/Makefile")

    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(machine "ppro")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(machine "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
        set(machine "ansi64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
        set(machine "ansi32")
    else()
        message(FATAL_ERROR "Unsupported architecture ${VCPKG_TARGET_ARCHITECTURE}")
    endif()

    set(target_suffix "dll")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(target_suffix "lib")
    endif()

    vcpkg_build_nmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH "libmpdec"
        TARGET "libmpdec-${VERSION}.${target_suffix}"
        OPTIONS
            MACHINE=${machine}
        OPTIONS_DEBUG
            DEBUG=1
    )

    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec/mpdecimal.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mpdecimal.h" "#elif defined(MPDECIMAL_DLL)" "#elif 1")

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec/libmpdec-${VERSION}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec/libmpdec-${VERSION}.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec/libmpdec-${VERSION}.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        if(NOT VCPKG_BUILD_TYPE)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec/libmpdec-${VERSION}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec/libmpdec-${VERSION}.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec/libmpdec-${VERSION}.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mpdecimal.h" "#elif defined(MPDECIMAL_DLL)" "#elif 0")

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec/libmpdec-${VERSION}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        if(NOT VCPKG_BUILD_TYPE)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec/libmpdec-${VERSION}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()

    file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    file(COPY "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/" DESTINATION "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")

    vcpkg_build_nmake(
        SOURCE_PATH "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}"
        PROJECT_SUBPATH "libmpdec++"
        TARGET "libmpdec++-${VERSION}.${target_suffix}"
        OPTIONS
            MACHINE=${machine}
        OPTIONS_DEBUG
            DEBUG=1
    )

    file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec++/decimal.hh" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/decimal.hh" "#elif defined(MPDECIMAL_DLL)" "#elif 1")

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec++/libmpdec++-${VERSION}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec++/libmpdec++-${VERSION}.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec++/libmpdec++-${VERSION}.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        if(NOT VCPKG_BUILD_TYPE)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec++/libmpdec++-${VERSION}.dll" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec++/libmpdec++-${VERSION}.dll.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec++/libmpdec++-${VERSION}.pdb" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        endif()
    else()
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/decimal.hh" "#elif defined(MPDECIMAL_DLL)" "#elif 0")

        file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libmpdec++/libmpdec++-${VERSION}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
        if(NOT VCPKG_BUILD_TYPE)
            file(INSTALL "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libmpdec++/libmpdec++-${VERSION}.lib" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
        endif()
    endif()
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTORECONF
    )
    vcpkg_make_install(TARGETS lib libcxx install)

    vcpkg_fixup_pkgconfig()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT.txt")
