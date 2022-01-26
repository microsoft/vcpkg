if(EXISTS "${CURRENT_INSTALLED_DIR}/include/gmp.h" OR "${CURRENT_INSTALLED_DIR}/include/gmpxx.h")
    message(FATAL_ERROR "Can't build ${PORT} if gmp is installed. Please remove gmp, and try to install ${PORT} again if you need it.")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static" AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "${PORT} currently can only be built using the dynamic CRT when building DLLs")
endif()

set(MPIR_VERSION 3.0.0)

if(VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
    vcpkg_download_distfile(
        ARCHIVE
        URLS "http://mpir.org/mpir-${MPIR_VERSION}.tar.bz2"
        FILENAME mpir-${MPIR_VERSION}.tar.bz2
        SHA512 c735105db8b86db739fd915bf16064e6bc82d0565ad8858059e4e93f62c9d72d9a1c02a5ca9859b184346a8dc64fa714d4d61404cff1e405dc548cbd54d0a88e
    )

    vcpkg_extract_source_archive_ex(
        OUT_SOURCE_PATH SOURCE_PATH
        ARCHIVE ${ARCHIVE}
        REF ${MPIR_VERSION}
    )

    vcpkg_find_acquire_program(YASM)

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(SHARED_STATIC --enable-static --disable-shared)
    else()
        set(SHARED_STATIC --disable-static --enable-shared)
    endif()

    set(OPTIONS --disable-silent-rules --enable-gmpcompat --enable-cxx ${SHARED_STATIC})

    string(APPEND VCPKG_C_FLAGS " -Wno-implicit-function-declaration")
    string(APPEND VCPKG_CXX_FLAGS " -Wno-implicit-function-declaration")

    # on Linux, autoconf is required; on macOS, it isn't
    if(VCPKG_TARGET_IS_LINUX)
        set(AUTOCONFIG "AUTOCONFIG")
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        ${AUTOCONFIG}
        OPTIONS ${OPTIONS}
    )

    vcpkg_install_make()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
        file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
    endif()

    configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO wbhart/mpir
        REF mpir-${MPIR_VERSION}
        SHA512 7d37f60645c533a6638dde5d9c48f5535022fa0ea02bafd5b714649c70814e88c5e5e3b0bef4c5a749aaf8772531de89c331716ee00ba1c2f9521c2cc8f3c61b
        HEAD_REF master
        PATCHES enable-runtimelibrary-toggle.patch
    )

    if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
        set(MSVC_VERSION 15)
    else()
        set(MSVC_VERSION 14)
    endif()

    if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(DLL_OR_LIB dll)
    else()
        set(DLL_OR_LIB lib)
    endif()

    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(RuntimeLibraryExt "")
    else()
        set(RuntimeLibraryExt "DLL")
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})
    file(GLOB FILES ${SOURCE_PATH}/*)
    file(COPY ${FILES} DESTINATION ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET})

    vcpkg_build_msbuild(
        PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/build.vc${MSVC_VERSION}/${DLL_OR_LIB}_mpir_gc/${DLL_OR_LIB}_mpir_gc.vcxproj
        OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
        OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
    )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        vcpkg_build_msbuild(
            PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/build.vc${MSVC_VERSION}/${DLL_OR_LIB}_mpir_cxx/${DLL_OR_LIB}_mpir_cxx.vcxproj
            OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
            OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
        )
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            file(GLOB REL_LIBS_CXX ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpirxx.lib)
        endif()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            file(GLOB DBG_LIBS_CXX ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpirxx.lib)
        endif()
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(GLOB HEADERS
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/gmp.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/gmpxx.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpirxx.h
        )
        file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

        file(GLOB REL_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.dll)
        file(GLOB REL_LIBS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.lib)
        list(APPEND REL_LIBS  ${REL_LIBS_CXX})

        file(INSTALL ${REL_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
        file(INSTALL ${REL_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(GLOB HEADERS
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/gmp.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/gmpxx.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpir.h
            ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpirxx.h
        )
        file(INSTALL ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

        file(GLOB DBG_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpir.dll)
        file(GLOB DBG_LIBS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpir.lib)
        list(APPEND DBG_LIBS  ${DBG_LIBS_CXX})

        file(INSTALL ${DBG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(INSTALL ${DBG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

        if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
            file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
        endif()
    endif()

    vcpkg_copy_pdbs()

    file(INSTALL ${SOURCE_PATH}/COPYING.lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
endif()
