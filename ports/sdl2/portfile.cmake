include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-2.0.10
    SHA512 c5fe59eed7ba9c6a82cceaf513623480793727fceec84b01d819e7cbefc8229a84be93067d7539f12d5811c49d3d54fd407272786aef3e419f439d0105c34b21
    HEAD_REF master
    PATCHES
        export-symbols-only-in-shared-build.patch
        enable-winrt-cmake.patch
        fix-arm64-headers.patch
        disable-hidapi-for-uwp.patch
        fix-space-in-path.patch
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

file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
configure_file(${SOURCE_PATH}/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
vcpkg_copy_pdbs()
