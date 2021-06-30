set(MPG123_VERSION 1.28.0)
set(MPG123_HASH 4e333ee4f3bbebcfff280cf286265e969a8da93b9043d03c0189e22cd40918b07bf12181bd06141d4479c78bc0d0ed472e0d3bb61b2fdb96fe9f7cd48f9a6b77)

set(PATCHES "")
if(VCPKG_TARGET_IS_UWP)
    set(PATCHES
        0002-fix-libmpg123-uwp-build.patch
        0003-fix-libout123-uwp-build.patch
        0004-fix-libsyn123-uwp-build.patch
    )
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
    PATCHES
        0001-fix-checkcpuarch-path.patch
        ${PATCHES}
)

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(APPEND_TO_PATH)

if(VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP)

    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}/ports/cmake
        OPTIONS -DUSE_MODULES=OFF
    )
    vcpkg_install_cmake()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

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
    vcpkg_fixup_pkgconfig()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

message(STATUS "Installing done")
