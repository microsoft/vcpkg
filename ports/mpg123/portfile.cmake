set(MPG123_VERSION 1.26.5)
set(MPG123_HASH 0c2b3174c834e4bd459a3324b825d9bf9341a3486c0af815773b00cb007578cb718522ac4e983c7ad7e3bb5df9fdd342a03cb51345c41f68971145196ac04b7a)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpg123/mpg123
    REF ${MPG123_VERSION}
    FILENAME "mpg123-${MPG123_VERSION}.tar.bz2"
    SHA512 ${MPG123_HASH}
)

include(${CURRENT_INSTALLED_DIR}/share/yasm-tool-helper/yasm-tool-helper.cmake)
yasm_tool_helper(APPEND_TO_PATH)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS)
        set(MPG123_OPTIONS "-DCMAKE_C_FLAGS=\/DBUILD_MPG123_DLL")
    endif()
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/ports/cmake
    OPTIONS ${MPG123_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES m)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
