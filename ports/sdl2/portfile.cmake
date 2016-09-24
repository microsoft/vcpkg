include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://libsdl.org/release/SDL2-2.0.4.tar.gz"
    FILENAME "SDL2-2.0.4.tar.gz"
    SHA512 dd0a95878639856c0f4b8a579ace8071379ab64519fa139b22d3ed857a0f0db87a75bc8480c7207e02fbffd1fdbd448e3c0b882c451675b0e2f1a945af02e1d6
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if(TRIPLET_SYSTEM_NAME MATCHES "WindowsStore")
    vcpkg_build_msbuild(
        PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/SDL-UWP.vcxproj
    )

    file(COPY
        ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.dll
        ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(COPY
        ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.dll
        ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.pdb
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(COPY ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Debug/SDL-UWP/SDL2.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/VisualC-WinRT/UWP_VS2015/Release/SDL-UWP/SDL2.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib)

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
    file(COPY ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    file(RENAME ${CURRENT_PACKAGES_DIR}/include/include ${CURRENT_PACKAGES_DIR}/include/SDL2)
else()
    vcpkg_configure_cmake(
        SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4
        OPTIONS
            -DSDL_STATIC=OFF
    )

    vcpkg_build_cmake()
    vcpkg_install_cmake()

    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/SDL2-2.0.4/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sdl2 RENAME copyright)
vcpkg_copy_pdbs()
