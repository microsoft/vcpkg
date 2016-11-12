if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.5)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://libsdl.org/release/SDL2-2.0.5.tar.gz"
    FILENAME "SDL2-2.0.5.tar.gz"
    SHA512 6401f5df08c08316c09bc6ac5b28345c5184bb25770baa5c94c0a582ae130ddf73bb736e44bb31f4e427c1ddbbeec4755a6a5f530b6b4c3d0f13ebc78ddc1750
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if(TRIPLET_SYSTEM_NAME MATCHES "WindowsStore")
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
    vcpkg_configure_cmake(
        SOURCE_PATH ${SOURCE_PATH}
        OPTIONS
            -DSDL_STATIC=OFF
    )

    vcpkg_install_cmake()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
