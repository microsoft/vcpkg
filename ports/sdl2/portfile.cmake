set(SDL2_VERSION 2.0.16)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL
    REF release-2.0.16
    SHA512 45ce71f77b01f5fd886f92e5b3d96f1f72c7e0f70c09e615384a900533b941cad65bf6b54a125a9eeb8499e2056e9a8e54d4e654bccfca9730584792a2b18fbc
    HEAD_REF master
    PATCHES
        0001-sdl2-Enable-creation-of-pkg-cfg-file-on-windows.patch
        0002-sdl2-skip-ibus-on-linux.patch
        0003-sdl2-disable-sdlmain-target-search-on-uwp.patch
        0004-sdl2-alias-on-static-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    vulkan  VIDEO_VULKAN
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DFORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        -DLIBC=ON
)

vcpkg_install_cmake()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/SDL2")
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/SDL2)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL2.framework/Resources")
    vcpkg_fixup_cmake_targets(CONFIG_PATH SDL2.framework/Resources)
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/bin/sdl2-config
    ${CURRENT_PACKAGES_DIR}/debug/bin/sdl2-config
    ${CURRENT_PACKAGES_DIR}/SDL2.framework
    ${CURRENT_PACKAGES_DIR}/debug/SDL2.framework
)

file(GLOB BINS ${CURRENT_PACKAGES_DIR}/debug/bin/* ${CURRENT_PACKAGES_DIR}/bin/*)
if(NOT BINS)
    file(REMOVE_RECURSE
        ${CURRENT_PACKAGES_DIR}/bin
        ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link)
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/SDL2main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/SDL2main.lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/SDL2maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDL2maind.lib)
    endif()

    file(GLOB SHARE_FILES ${CURRENT_PACKAGES_DIR}/share/sdl2/*.cmake)
    foreach(SHARE_FILE ${SHARE_FILES})
        vcpkg_replace_string("${SHARE_FILE}" "lib/SDL2main" "lib/manual-link/SDL2main")
    endforeach()
endif()

configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
vcpkg_copy_pdbs()

set(DYLIB_COMPATIBILITY_VERSION_REGEX "set\\(DYLIB_COMPATIBILITY_VERSION (.+)\\)")
set(DYLIB_CURRENT_VERSION_REGEX "set\\(DYLIB_CURRENT_VERSION (.+)\\)")
file(STRINGS "${SOURCE_PATH}/CMakeLists.txt" DYLIB_COMPATIBILITY_VERSION REGEX ${DYLIB_COMPATIBILITY_VERSION_REGEX})
file(STRINGS "${SOURCE_PATH}/CMakeLists.txt" DYLIB_CURRENT_VERSION REGEX ${DYLIB_CURRENT_VERSION_REGEX})
string(REGEX REPLACE ${DYLIB_COMPATIBILITY_VERSION_REGEX} "\\1" DYLIB_COMPATIBILITY_VERSION "${DYLIB_COMPATIBILITY_VERSION}")
string(REGEX REPLACE ${DYLIB_CURRENT_VERSION_REGEX} "\\1" DYLIB_CURRENT_VERSION "${DYLIB_CURRENT_VERSION}")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/sdl2.pc" "-lSDL2main" "-lSDL2maind")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/sdl2.pc" "-lSDL2 " "-lSDL2d ")
endif()

vcpkg_fixup_pkgconfig()
