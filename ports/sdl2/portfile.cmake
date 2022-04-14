set(SDL2_VERSION 2.0.20)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL
    REF release-2.0.20
    SHA512 f8558057a06d4507190b369b2067aee55c22ab796b90bb663fbc36218e66ec14e2feb0ecd55f9b798bfd24fc94e2b4cb93eddc52a59f0709d6cb0ebdb6d9309b
    HEAD_REF master
    PATCHES
        0001-sdl2-Enable-creation-of-pkg-cfg-file-on-windows.patch
        0002-sdl2-skip-ibus-on-linux.patch
        0003-sdl2-disable-sdlmain-target-search-on-uwp.patch
        0004-Define-crt-macros.patch
        0005-Fix-uwp-joystick.patch
        0006-Update-SDL_sysurl.cpp.patch
        0007-timer-Fix-Emscripten-declaration-after-statement-err.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        vulkan  SDL_VULKAN
        x11     SDL_X11_SHARED
)

if ("x11" IN_LIST FEATURES)
    if (VCPKG_TARGET_IS_WINDOWS)
        message(FATAL_ERROR "Feature x11 only support UNIX.")
    endif()
    message(WARNING "You will need to install Xorg dependencies to use feature x11:\nsudo apt install libx11-dev libxft-dev libxext-dev\n")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DSDL_FORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        -DSDL_LIBC=ON
)

vcpkg_cmake_install()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/SDL2")
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SDL2)
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL2.framework/Resources")
    vcpkg_cmake_config_fixup(CONFIG_PATH SDL2.framework/Resources)
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin/sdl2-config"
    "${CURRENT_PACKAGES_DIR}/debug/bin/sdl2-config"
    "${CURRENT_PACKAGES_DIR}/SDL2.framework"
    "${CURRENT_PACKAGES_DIR}/debug/SDL2.framework"
)

file(GLOB BINS "${CURRENT_PACKAGES_DIR}/debug/bin/*" "${CURRENT_PACKAGES_DIR}/bin/*")
if(NOT BINS)
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/bin"
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP AND NOT VCPKG_TARGET_IS_MINGW)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/SDL2main.lib" "${CURRENT_PACKAGES_DIR}/lib/manual-link/SDL2main.lib")
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/SDL2maind.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDL2maind.lib")
    endif()

    file(GLOB SHARE_FILES "${CURRENT_PACKAGES_DIR}/share/sdl2/*.cmake")
    foreach(SHARE_FILE ${SHARE_FILES})
        vcpkg_replace_string("${SHARE_FILE}" "lib/SDL2main" "lib/manual-link/SDL2main")
    endforeach()
endif()

configure_file("${SOURCE_PATH}/LICENSE.txt" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)
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
