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

vcpkg_download_distfile(ARCHIVE
    URLS "http://downloads.sourceforge.net/project/mpg123/mpg123/${MPG123_VERSION}/mpg123-${MPG123_VERSION}.tar.bz2"
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
)

vcpkg_extract_source_archive_ex(
    ARCHIVE ${ARCHIVE}
    OUT_SOURCE_PATH SOURCE_PATH
    PATCHES
        0001-fix-crt-linking.patch
        0002-fix-x86-build.patch
        0003-add-arm-configs.patch
)

vcpkg_find_acquire_program(YASM)
get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/ports/MSVC++/2015/win32/libmpg123/libmpg123.vcxproj
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
elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    file(REMOVE_RECURSE ${SOURCE_PATH}/build/debug)
    file(REMOVE_RECURSE ${SOURCE_PATH}/build/release)

    ################
    # Debug build
    ################
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND "${SOURCE_PATH}/configure" --prefix=${SOURCE_PATH}/build/debug --enable-debug=yes --enable-static=yes --disable-dependency-tracking --with-default-audio=coreaudio --with-module-suffix=.so
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-dbg done.")

    message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
    vcpkg_execute_required_process(
        COMMAND make -j install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-dbg
    )
    message(STATUS "Installing ${TARGET_TRIPLET}-dbg done.")

    ################
    # Release build
    ################
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND make distclean
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME config-${TARGET_TRIPLET}-dbg
    )
    vcpkg_execute_required_process(
        COMMAND "${SOURCE_PATH}/configure" --prefix=${SOURCE_PATH}/build/release --enable-static=yes --disable-dependency-tracking --with-default-audio=coreaudio --with-module-suffix=.so
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME config-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Configuring ${TARGET_TRIPLET}-rel done.")

    message(STATUS "Installing ${TARGET_TRIPLET}-rel")
    vcpkg_execute_required_process(
        COMMAND make -j install
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME build-${TARGET_TRIPLET}-rel
    )
    message(STATUS "Installing ${TARGET_TRIPLET}-rel done.")

    file(
        INSTALL
            "${SOURCE_PATH}/build/debug/include/fmt123.h"
            "${SOURCE_PATH}/build/debug/include/mpg123.h"
            "${SOURCE_PATH}/build/debug/include/out123.h"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/include
    )

    file(
        INSTALL
            "${SOURCE_PATH}/build/debug/lib/libmpg123.a"
            "${SOURCE_PATH}/build/debug/lib/libout123.a"
        DESTINATION
            ${CURRENT_INSTALLED_DIR}/debug/lib
    )

    file(
        INSTALL
            "${SOURCE_PATH}/build/release/lib/libmpg123.a"
            "${SOURCE_PATH}/build/release/lib/libout123.a"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/lib
    )
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/mpg123 RENAME copyright)

message(STATUS "Installing done")
