include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "MPIR currently can only be built for desktop")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static" AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "MPIR currently can only be built using the dynamic CRT when building DLLs")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wbhart/mpir
    REF mpir-3.0.0
    SHA512 7d37f60645c533a6638dde5d9c48f5535022fa0ea02bafd5b714649c70814e88c5e5e3b0bef4c5a749aaf8772531de89c331716ee00ba1c2f9521c2cc8f3c61b
    HEAD_REF master
)

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
