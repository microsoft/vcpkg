include(vcpkg_common_functions)

set(SDL2_VERSION 2.0.7)
set(SDL2_HASH eed5477843086a0e66552eb197a5c4929134522bc366d873732361ea0df5fb841ef7e2b1913e21d1bae69e6fd3152ee630492e615c58cbe903e7d6e47b587410)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2-${SDL2_VERSION})
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://libsdl.org/release/SDL2-${SDL2_VERSION}.tar.gz"
    FILENAME "SDL2-${SDL2_VERSION}.tar.gz"
    SHA512 ${SDL2_HASH}
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

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

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/manual-link ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/SDL2main.lib ${CURRENT_PACKAGES_DIR}/lib/manual-link/SDL2main.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/SDL2maind.lib ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link/SDL2maind.lib)

    file(GLOB SHARE_FILES ${CURRENT_PACKAGES_DIR}/share/sdl2/*.cmake)
    foreach(SHARE_FILE ${SHARE_FILES})
        file(READ "${SHARE_FILE}" _contents)
        string(REPLACE "lib/SDL2main" "lib/manual-link/SDL2main" _contents "${_contents}")
        file(WRITE "${SHARE_FILE}" "${_contents}")
    endforeach()
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
