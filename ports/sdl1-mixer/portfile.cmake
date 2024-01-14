vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF d8b2c98ca3db62fa3d4e1dbb8801c6f57a10b8bf
    SHA512 e22b2e26d9c7296e79589d5108118c65f5fb76e7e9d6996129e19b63313f9aa3a4c0657010e45fa040792fa81c488dae3ec6fac09e147d3b4430d612837e0132
    HEAD_REF SDL-1.2
    PATCHES
        mpg123_ssize_t.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/SDL_mixer_2017.sln.in" "${SOURCE_PATH}/VisualC/SDL_mixer_2017.sln" COPYONLY)
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(LIB_TYPE StaticLibrary)
    else()
        set(LIB_TYPE DynamicLibrary)
    endif()
    
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(CRT_TYPE_DBG MultiThreadedDebugDLL)
        set(CRT_TYPE_REL MultiThreadedDLL)
    else()
        set(CRT_TYPE_DBG MultiThreadedDebug)
        set(CRT_TYPE_REL MultiThreaded)
    endif()
    
    configure_file("${CURRENT_PORT_DIR}/SDL_mixer.vcxproj.in" "${SOURCE_PATH}/VisualC/SDL_mixer.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/native_midi.vcxproj.in" "${SOURCE_PATH}/VisualC/native_midi/native_midi.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/timidity.vcxproj.in" "${SOURCE_PATH}/VisualC/timidity/timidity.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/playmus.vcxproj.in" "${SOURCE_PATH}/VisualC/playmus/playmus.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/playwave.vcxproj.in" "${SOURCE_PATH}/VisualC/playwave/playwave.vcxproj" @ONLY)
    
    # This text file gets copied as a library, and included as one in the package 
    file(REMOVE "${SOURCE_PATH}/external/libmikmod/COPYING.LIB")

    # Remove unused external dlls
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libFLAC-8.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libmikmod-2.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libmpg123-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libogg-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libvorbis-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libvorbisfile-3.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libFLAC-8.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libmikmod-2.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libmpg123-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libogg-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libvorbis-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libvorbisfile-3.dll")
    
    file(WRITE "${SOURCE_PATH}/Directory.Build.props" "<?xml version=\"1.0\" encoding=\"utf-8\"?>
                                                     <Project xmlns=\"http://schemas.microsoft.com/developer/msbuild/2003\">
                                                     <ItemDefinitionGroup>
                                                     <ClCompile>
                                                     <AdditionalIncludeDirectories>${CURRENT_PACKAGES_DIR}/include;${CURRENT_PACKAGES_DIR}/include/SDL;${CURRENT_INSTALLED_DIR}/include;${CURRENT_INSTALLED_DIR}/include/SDL</AdditionalIncludeDirectories>
                                                     </ClCompile>
                                                     </ItemDefinitionGroup>
                                                     </Project>")

    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH VisualC/SDL_mixer_2017.sln
        #INCLUDES_SUBPATH include
        LICENSE_SUBPATH COPYING
        #ALLOW_ROOT_INCLUDES
    )
    file(COPY "${SOURCE_PATH}/SDL_mixer.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/SDL")
else()
    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
