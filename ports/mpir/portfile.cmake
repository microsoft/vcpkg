include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "MPIR currently can only be built for desktop")
endif()

if(VCPKG_CRT_LINKAGE STREQUAL "static" AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(FATAL_ERROR "MPIR currently can only be built using the dynamic CRT when building DLLs")
endif()

set(MPIR_VERSION 3.0.0)

if(VCPKG_CMAKE_SYSTEM_NAME)
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

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    set(ENV{CXXFLAGS} "${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_DEBUG} -O0 -g")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_DEBUG} -O0 -g")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    vcpkg_execute_required_process(
        COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR}/debug ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}/debug
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME configure-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Building ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND make -j install
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
        LOGNAME install-${TARGET_TRIPLET}-dbg
    )

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    set(ENV{CXXFLAGS} "${VCPKG_CXX_FLAGS} ${VCPKG_CXX_FLAGS_RELEASE} -O2")
    set(ENV{CFLAGS} "${VCPKG_C_FLAGS} ${VCPKG_C_FLAGS_RELEASE} -O2")
    set(ENV{LDFLAGS} "${VCPKG_LINKER_FLAGS}")
    vcpkg_execute_required_process(
        COMMAND ${SOURCE_PATH}/configure --prefix=${CURRENT_PACKAGES_DIR} ${OPTIONS} --with-sysroot=${CURRENT_INSTALLED_DIR}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME configure-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Building ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND make -j install
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
        LOGNAME install-${TARGET_TRIPLET}-rel
    )

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/info)
    configure_file(${SOURCE_PATH}/COPYING.lib ${CURRENT_PACKAGES_DIR}/share/mpir/copyright COPYONLY)
else()
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

    file(GLOB HEADERS
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/gmp.h
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/gmpxx.h
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.h
        ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpirxx.h
    )
    file(COPY ${HEADERS} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

    file(GLOB REL_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.dll)
    file(GLOB REL_LIBS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Release/mpir.lib)

    file(GLOB DBG_DLLS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpir.dll)
    file(GLOB DBG_LIBS ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}/*/*/Debug/mpir.lib)

    file(COPY ${REL_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${REL_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${DBG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY ${DBG_LIBS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    vcpkg_copy_pdbs()

    configure_file(${SOURCE_PATH}/COPYING.lib ${CURRENT_PACKAGES_DIR}/share/mpir/copyright COPYONLY)
endif()
