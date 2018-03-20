include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SDL-Mirror/SDL
    REF release-2.0.8
    SHA512 5922dbeb14bb22991160251664b417d3f846867c18b5ecc1bd19c328ffd69b16252b7d45b9a317bafd1207fdb66d93a022dfb239e02447db9babd941956b6b37
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/export-symbols-only-in-shared-build.patch
        ${CMAKE_CURRENT_LIST_DIR}/enable-winrt-cmake.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SDL_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SDL_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" FORCE_STATIC_VCRT)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSDL_STATIC=${SDL_STATIC}
        -DSDL_SHARED=${SDL_SHARED}
        -DVIDEO_VULKAN=OFF
        -DFORCE_STATIC_VCRT=${FORCE_STATIC_VCRT}
        -DLIBC=ON
)

vcpkg_install_cmake()

if(EXISTS "${CURRENT_PACKAGES_DIR}/cmake")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/lib/cmake/SDL2")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/SDL2")
elseif(EXISTS "${CURRENT_PACKAGES_DIR}/SDL2.framework/Resources")
    vcpkg_fixup_cmake_targets(CONFIG_PATH "SDL2.framework/Resources")
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

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
