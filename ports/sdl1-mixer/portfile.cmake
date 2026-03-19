vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF 4c93e0b4bcc3d5ecfd865190f664de6b2c837018
    SHA512 a6beed48c7a804aa5e52c3883edb6edd09b073ffec3481ce5fb27fee020ca4364525d0760e0532d3233a5e0f1500780c2994d9bb9ffcf79047bb6766b818bb0e
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

    vcpkg_msbuild_install(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH VisualC/SDL_mixer_2017.sln
    )
    file(COPY "${SOURCE_PATH}/SDL_mixer.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/SDL")
else()
    vcpkg_make_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
            --enable-music-fluidsynth-midi=no
            INCLUDE=#[[ empty ]]
    )
    vcpkg_make_install()
    vcpkg_fixup_pkgconfig()
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
