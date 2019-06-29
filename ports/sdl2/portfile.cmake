include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-2.0.9
    SHA512 444c906c0baa720c86ca72d1b4cd66fdf6f516d5d2a9836169081a2997a5aebaaf9caa687ec060fa02292d79cfa4a62442333e00f90a0239edd1601529f6b056
    HEAD_REF master
    PATCHES
        export-symbols-only-in-shared-build.patch
        fix-x86-windows.patch
        enable-winrt-cmake.patch
        SDL-2.0.9-bug-4391-fix.patch # See: https://bugzilla.libsdl.org/show_bug.cgi?id=4391 # Can be removed once SDL 2.0.10 is released
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

set(VULKAN_VIDEO OFF)
if("vulkan" IN_LIST FEATURES)
    set(VULKAN_VIDEO ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DVIDEO_VULKAN=${VULKAN_VIDEO}
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
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/SDL2main" "lib/manual-link/SDL2main" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2)
configure_file(${SOURCE_PATH}/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/sdl2/copyright COPYONLY)
vcpkg_copy_pdbs()
