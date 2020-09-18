set(MPG123_VERSION 1.25.8)
set(MPG123_HASH f226317dddb07841a13753603fa13c0a867605a5a051626cb30d45cfba266d3d4296f5b8254f65b403bb5eef6addce1784ae8829b671a746854785cda1bad203)

#architecture detection
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
   set(MPG123_ARCH Win32)
   set(MPG123_CONFIGURATION _x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
   set(MPG123_ARCH x64)
   set(MPG123_CONFIGURATION _x86)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
   set(MPG123_ARCH ARM)
   set(MPG123_CONFIGURATION _Generic)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
   set(MPG123_ARCH ARM64)
   set(MPG123_CONFIGURATION _Generic)
else()
   message(FATAL_ERROR "unsupported architecture")
endif()

#linking
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(MPG123_CONFIGURATION_SUFFIX _Dll)
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
    PATCHES
        0001-fix-crt-linking.patch
        0002-fix-x86-build.patch
        0003-add-arm-configs.patch
        0004-add-arm64-uwp-config.patch
)

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")

if(VCPKG_TARGET_IS_UWP)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/libmpg123.vcxproj
        OPTIONS /p:UseEnv=True
    )

    message(STATUS "Installing")
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Debug/libmpg123/libmpg123.dll
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Debug/libmpg123/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Debug/libmpg123/libmpg123.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Release/libmpg123/libmpg123.dll
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Release/libmpg123/libmpg123.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/uwp/libmpg123/${MPG123_ARCH}/Release/libmpg123/libmpg123.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/mpg123.h
        ${SOURCE_PATH}/src/libmpg123/fmt123.h
        ${SOURCE_PATH}/src/libmpg123/mpg123.h.in
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
elseif(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/libmpg123.vcxproj
        OPTIONS /p:UseEnv=True
        RELEASE_CONFIGURATION Release${MPG123_CONFIGURATION}${MPG123_CONFIGURATION_SUFFIX}
        DEBUG_CONFIGURATION Debug${MPG123_CONFIGURATION}${MPG123_CONFIGURATION_SUFFIX}
    )

    message(STATUS "Installing")
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(INSTALL
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.dll
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.pdb
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
        )
        file(INSTALL
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.dll
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.pdb
            DESTINATION ${CURRENT_PACKAGES_DIR}/bin
        )
    else()
        file(INSTALL
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug_x86/libmpg123.pdb
            DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
        )
        file(INSTALL
            ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release_x86/libmpg123.pdb
            DESTINATION ${CURRENT_PACKAGES_DIR}/lib
        )
    endif()

    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Debug/libmpg123.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/${MPG123_ARCH}/Release/libmpg123.lib
        DESTINATION ${CURRENT_PACKAGES_DIR}/lib
    )
    file(INSTALL
        ${SOURCE_PATH}/ports/MSVC++/mpg123.h
        ${SOURCE_PATH}/src/libmpg123/fmt123.h
        ${SOURCE_PATH}/src/libmpg123/mpg123.h.in
        DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
elseif(VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_LINUX)
    set(MPG123_OPTIONS
        --disable-dependency-tracking
    )

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
        file(READ ${CURRENT_BUILDTREES_DIR}/dumpmachine-${TARGET_TRIPLET}-out.log MPG123_HOST)
        string(REPLACE "\n" "" MPG123_HOST "${MPG123_HOST}")
        message(STATUS "Cross-compiling with ${CMAKE_C_COMPILER}")
        message(STATUS "Detected autoconf triplet --host=${MPG123_HOST}")
        set(MPG123_OPTIONS
            --host=${MPG123_HOST}
            ${MPG123_OPTIONS}
        )
    endif()

    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS ${MPG123_OPTIONS}
    )
    vcpkg_install_make()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

message(STATUS "Installing done")
