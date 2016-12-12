include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.5)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://libsdl.org/release/SDL2-2.0.5.tar.gz"
    FILENAME "SDL2-2.0.5.tar.gz"
    SHA512 6401f5df08c08316c09bc6ac5b28345c5184bb25770baa5c94c0a582ae130ddf73bb736e44bb31f4e427c1ddbbeec4755a6a5f530b6b4c3d0f13ebc78ddc1750
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

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
    )

    vcpkg_install_cmake()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

file(COPY ${CURRENT_PACKAGES_DIR}/lib/SDL2main.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/SDL2main.lib)
file(COPY ${CURRENT_PACKAGES_DIR}/debug/lib/SDL2main.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/manual-link)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib/SDL2main.lib)

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
