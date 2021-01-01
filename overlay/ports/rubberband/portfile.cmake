vcpkg_download_distfile(ARCHIVE
    URLS "https://breakfastquay.com/files/releases/rubberband-1.9.0.tar.bz2"
    FILENAME "rubberband-1.9.0.tar.bz2"
    SHA512 2226cfec98f280a12f874f60620c3bf09f7399a7808af5e9f5c9a5154b989cfbf3c4220e162d722e319a4ef046f81c6a07eac2b8c6035c8f6230f0a20b1577a8
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES runtime-library.patch
)

#architecture detection
if(VCPKG_TARGET_IS_WINDOWS)
    # Platform
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(RUBBERBAND_PLATFORM Win32)
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(RUBBERBAND_PLATFORM x64)
    else()
        message(FATAL_ERROR "unsupported architecture")
    endif()

    # Linking
    if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(RUBBERBAND_TARGET rubberband-library)
        set(RUBBERBAND_CRT_LINKAGE_RELEASE MultiThreaded)
        set(RUBBERBAND_CRT_LINKAGE_DEBUG MultiThreadedDebug)
    else()
        set(RUBBERBAND_TARGET rubberband-dll)
        set(RUBBERBAND_CRT_LINKAGE_RELEASE MultiThreadedDLL)
        set(RUBBERBAND_CRT_LINKAGE_DEBUG MultiThreadedDebugDLL)
    endif()

    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH rubberband.sln
        PLATFORM ${RUBBERBAND_PLATFORM}
        TARGET ${RUBBERBAND_TARGET}
        OPTIONS
            /p:UseEnv=True
            /p:RubberbandRuntimeLibraryRelease=${RUBBERBAND_CRT_LINKAGE_RELEASE}
            /p:RubberbandRuntimeLibraryDebug=${RUBBERBAND_CRT_LINKAGE_DEBUG}
    )

    file(INSTALL
        ${SOURCE_PATH}/rubberband/rubberband-c.h
        ${SOURCE_PATH}/rubberband/RubberBandStretcher.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include/rubberband
    )
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    set(RUBBERBAND_OPTIONS --disable-programs)

    # Find cross-compiler prefix
    if(VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        include("${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}")
    endif()
    if(CMAKE_C_COMPILER)
        vcpkg_execute_required_process(
            COMMAND ${CMAKE_C_COMPILER} -dumpmachine
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}
            LOGNAME dumpmachine-${TARGET_TRIPLET}
        )
        file(READ ${CURRENT_BUILDTREES_DIR}/dumpmachine-${TARGET_TRIPLET}-out.log RUBBERBAND_HOST)
        string(REPLACE "\n" "" RUBBERBAND_HOST "${RUBBERBAND_HOST}")
        message(STATUS "Cross-compiling with ${CMAKE_C_COMPILER}")
        message(STATUS "Detected autoconf triplet --host=${RUBBERBAND_HOST}")
        message(STATUS "Options ${RUBBERBAND_OPTIONS}")
        set(RUBBERBAND_OPTIONS
            --host=${RUBBERBAND_HOST}
            ${RUBBERBAND_OPTIONS}
        )
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        COPY_SOURCE
        OPTIONS ${RUBBERBAND_OPTIONS}
    )
    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
    configure_file("${SOURCE_PATH}/COPYING" "${CURRENT_PACKAGES_DIR}/share/rubberband/copyright" COPYONLY)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/rubberband RENAME copyright)
