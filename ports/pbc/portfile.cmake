if(NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(
        ARCHIVE
        URLS "https://crypto.stanford.edu/pbc/files/pbc-${VERSION}.tar.gz"
        FILENAME pbc-${VERSION}.tar.gz
        SHA512 d75d4ceb3f67ee62c7ca41e2a91ee914fbffaeb70256675aed6734d586950ea8e64e2f16dc069d71481eddb703624df8d46497005fb58e75cf098dd7e7961333
    )

    vcpkg_extract_source_archive(
        SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        SOURCE_BASE "${VERSION}"
        PATCHES linux.patch
    )

    vcpkg_find_acquire_program(BISON)
    vcpkg_find_acquire_program(FLEX)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SHARED_STATIC --enable-static --disable-shared)
    else()
        set(SHARED_STATIC --disable-static --enable-shared)
    endif()

    set(OPTIONS ${SHARED_STATIC} LEX=${FLEX} YACC=${BISON}\ -y)

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
        AUTOCONFIG
        COPY_SOURCE
        OPTIONS
            ${OPTIONS}
    )

    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/info")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
else()
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO blynn/pbc
        REF fbf4589036ce4f662e2d06905862c9e816cf9d08
        SHA512 9348afd3866090b9fca189ae3a6bbb86c842b5f6ee7e1972f1a579993e589952c5926cb0795d4db1e647e3af263827e22c7602314c39bd97e03ffe9ad0fb48ab
        HEAD_REF master
        PATCHES windows.patch
    )

    set(CMAKE_FIND_LIBRARY_PREFIXES "")
    set(CMAKE_FIND_LIBRARY_SUFFIXES "")

    find_path(MPIR_INCLUDE_DIR "gmp.h" HINTS ${CURRENT_INSTALLED_DIR} PATH_SUFFIXES include)
    if(NOT MPIR_INCLUDE_DIR)
        message(FATAL_ERROR "GMP includes not found")
    endif()

    find_library(MPIR_LIBRARIES_REL NAMES "mpir.lib" HINTS ${CURRENT_INSTALLED_DIR} PATH_SUFFIXES lib)
    if(NOT MPIR_LIBRARIES_REL)
        message(FATAL_ERROR "mpir library not found")
    endif()

    find_library(MPIR_LIBRARIES_DBG NAMES "mpir.lib" HINTS ${CURRENT_INSTALLED_DIR} PATH_SUFFIXES debug/lib)
    if(NOT MPIR_LIBRARIES_DBG)
        message(FATAL_ERROR "mpir debug library not found")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(LibrarySuffix "lib")
        set(ConfigurationSuffix "")
    else()
        set(LibrarySuffix "dll")
        set(ConfigurationSuffix " DLL")
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(RuntimeLibraryExt "")
    else()
        set(RuntimeLibraryExt "DLL")
    endif()

    if(TRIPLET_SYSTEM_ARCH STREQUAL "x86")
        set(Platform "Win32")
    else()
        set(Platform ${TRIPLET_SYSTEM_ARCH})
    endif()

    # PBC expects mpir directory in build root
    get_filename_component(SOURCE_PATH_PARENT ${SOURCE_PATH} DIRECTORY)
    file(REMOVE_RECURSE ${SOURCE_PATH_PARENT}/mpir)
    file(MAKE_DIRECTORY ${SOURCE_PATH_PARENT}/mpir)
    file(GLOB FILES ${MPIR_INCLUDE_DIR}/gmp*.h)
    file(COPY ${FILES} ${MPIR_LIBRARIES_REL} DESTINATION "${SOURCE_PATH_PARENT}/mpir/${LibrarySuffix}/${Platform}/Release")
    file(COPY ${FILES} ${MPIR_LIBRARIES_DBG} DESTINATION "${SOURCE_PATH_PARENT}/mpir/${LibrarySuffix}/${Platform}/Debug")

    get_filename_component(SOURCE_PATH_SUFFIX ${SOURCE_PATH} NAME)
    vcpkg_install_msbuild(SOURCE_PATH ${SOURCE_PATH_PARENT}
        PROJECT_SUBPATH ${SOURCE_PATH_SUFFIX}/pbcwin/projects/pbclib.vcxproj
        INCLUDES_SUBPATH ${SOURCE_PATH_SUFFIX}/include
        LICENSE_SUBPATH ${SOURCE_PATH_SUFFIX}/COPYING
        RELEASE_CONFIGURATION "Release${ConfigurationSuffix}"
        DEBUG_CONFIGURATION "Debug${ConfigurationSuffix}"
        OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
        OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
        OPTIONS /p:SolutionDir=../
        ALLOW_ROOT_INCLUDES
    )

    # clean up mpir stuff
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/mpir.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/mpir.lib")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-pbc-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")
endif()
