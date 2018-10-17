include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-1.2.15
    SHA512 38b94a650ec205377ae1503d0ec8a5254ef6d50ed0acac8d985b57b64bc16ea042cfa41e19e5ef8317980c4afb83186829f5bc3da9433d0a649dfd10554801b5
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/export-symbols-only-in-shared-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

file(INSTALL ${SOURCE_PATH}/include/SDL_config.h.default DESTINATION ${SOURCE_PATH}/include/ RENAME SDL_config.h)

vcpkg_install_msbuild(
    SOURCE_PATH ${SOURCE_PATH}
    PROJECT_SUBPATH VisualC/SDL.sln
    INCLUDES_SUBPATH include
    LICENSE_SUBPATH COPYING
    PLATFORM Win32
    OPTIONS
        /p:SDL_STATIC=${SDL_STATIC}
        /p:SDL_SHARED=${SDL_SHARED}
        /p:VIDEO_VULKAN=OFF
        /p:FORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        /p:LIBC=ON
    REMOVE_ROOT_INCLUDES
    USE_VCPKG_INTEGRATION
)

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/SDL")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/SDL")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL.framework/Resources")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "SDL.framework/Resources")
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
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
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/SDLmain.lib)
    endif()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/SDLmain.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDLmaind.lib)
    endif()

    file(GLOB SHARE_FILES ${CURRENT_PACKAGES_DIR}/share/sdl/*.cmake)
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/SDLmain" "lib/manual-link/SDLmain" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include RENAME SDL1)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl1 RENAME copyright)
vcpkg_copy_pdbs()
