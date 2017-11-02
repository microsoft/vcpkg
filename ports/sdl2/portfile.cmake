include(vcpkg_common_functions)

set(SDL2_VERSION 2.0.6)
set(SDL2_HASH ad4dad5663834ee0ffbdca1b531d753449b260c9256df2c48da7261aacd9795d91eef1286525cf914f6b92ba5985de7798f041557574b5d978b8224f10041830)

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
)

if(VCPKG_CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    vcpkg_build_msbuild(
        PROJECT_PATH ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/SDL-UWP.vcxproj
    )

    file(COPY
        ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.dll
        ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY
        ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.dll
        ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${SOURCE_PATH}/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
    file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(RENAME ${CURRENT_PACKAGES_DIR}/include/include ${CURRENT_PACKAGES_DIR}/include/SDL2)
else()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
        set(SDL_STATIC_LIB ON)
        set(SDL_SHARED_LIB OFF)
    else()
        set(SDL_STATIC_LIB OFF)
        set(SDL_SHARED_LIB ON)
    endif()
    if(VCPKG_CRT_LINKAGE STREQUAL static)
        set(SDL_STATIC_CRT ON)
    else()
        set(SDL_STATIC_CRT OFF)
    endif()
    
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DSDL_STATIC=${SDL_STATIC_LIB}
            -DSDL_SHARED=${SDL_SHARED_LIB}
            -DFORCE_STATIC_VCRT=${SDL_STATIC_CRT}
            -DLIBC=ON
    )

    vcpkg_install_cmake()
       
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

    vcpkg_fixup_cmake_targets(CONFIG_PATH "cmake")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
