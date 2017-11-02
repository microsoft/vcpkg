include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "MPIR currently can only be built for desktop")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static" AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "MPIR currently can only be built using the dynamic CRT when building DLLs")
endif()

set(MPIR_VERSION 3.0.0)
set(MPIR_HASH "c735105db8b86db739fd915bf16064e6bc82d0565ad8858059e4e93f62c9d72d9a1c02a5ca9859b184346a8dc64fa714d4d61404cff1e405dc548cbd54d0a88e")
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/mpir-${MPIR_VERSION})

vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://mpir.org/mpir-${MPIR_VERSION}.tar.bz2"
    FILENAME "mpir-${MPIR_VERSION}.tar.bz2"
    SHA512 ${MPIR_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/enable-runtimelibrary-toggle.patch"
)

if(VCPKG_PLATFORM_TOOLSET MATCHES "v141")
    set(MSVC_VERSION 15)
else()
    set(MSVC_VERSION 14)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/build.vc${MSVC_VERSION}/dll_mpir_gc/dll_mpir_gc.vcxproj
    )
else()
    if(VCPKG_CRT_LINKAGE STREQUAL "static")
        set(RuntimeLibraryExt "")
    else()
        set(RuntimeLibraryExt "DLL")
    endif()
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/build.vc${MSVC_VERSION}/lib_mpir_gc/lib_mpir_gc.vcxproj
        OPTIONS_DEBUG "/p:RuntimeLibrary=MultiThreadedDebug${RuntimeLibraryExt}"
        OPTIONS_RELEASE "/p:RuntimeLibrary=MultiThreaded${RuntimeLibraryExt}"
    )
endif()

IF (VCPKG_TARGET_ARCHITECTURE MATCHES "x86")
    SET(BUILD_ARCH "Win32")
ELSE()
    SET(BUILD_ARCH ${VCPKG_TARGET_ARCHITECTURE})
ENDIF()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(INSTALL
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/gmp.h
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/gmpxx.h
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.h
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpirxx.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
    file(INSTALL
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/mpir.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Debug/mpir.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/dll/${BUILD_ARCH}/Release/mpir.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
else()
    file(INSTALL
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/gmp.h
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/gmpxx.h
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpir.h
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpirxx.h
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
    file(INSTALL
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Debug/mpir.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/lib/${BUILD_ARCH}/Release/mpir.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.lib DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpir RENAME copyright)
vcpkg_copy_pdbs()

message(STATUS "Installing done")
