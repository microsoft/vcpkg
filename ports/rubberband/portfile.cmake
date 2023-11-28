vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO breakfastquay/rubberband
    REF "v${VERSION}"
    SHA512 6d7ce80f47a5870920748d6e2ff9425f9d90e3fd2d62d7b937158ad2134829bc1d1e34ec4fd6327de5d6f1924b4bb793dc4c9d10574102e11338383c4522ba84
    HEAD_REF default
)


if("cli" IN_LIST FEATURES)
    set(CLI_FEATURE enabled)
else()    
    set(CLI_FEATURE disabled)
endif()

# Select fastest available FFT library according https://github.com/breakfastquay/rubberband/blob/default/COMPILING.md#fft-libraries-supported
if(VCPKG_TARGET_IS_WINDOWS AND (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64"))
    set(FFT_LIB "fftw")
elseif(VCPKG_TARGET_IS_OSX AND VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(FFT_LIB "fftw")
else()
    set(FFT_LIB "sleef")
endif()

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dfft=${FFT_LIB}           # 'auto', 'builtin', 'kissfft', 'fftw', sleef', 'vdsp', 'ipp' 'FFT library to use. The default (auto) will use vDSP if available, the builtin implementation otherwise.')
        -Dresampler=libsamplerate  # 'auto', 'builtin', 'libsamplerate', 'speex', 'libspeexdsp', 'ipp' 'Resampler library to use. The default (auto) simply uses the builtin implementation.'
        -Dipp_path=                # 'Path to Intel IPP libraries, if selected for any of the other options.'
        -Dextra_include_dirs=      # 'Additional local header directories to search for dependencies.'
        -Dextra_lib_dirs=          # 'Additional local library directories to search for dependencies.'
        -Djni=disabled             # 'auto', 'disabled', 'enabled'
        -Dladspa=disabled          # 'auto', 'disabled', 'enabled'
        -Dlv2=disabled             # 'auto', 'disabled', 'enabled' lv2 feature is not yet supported yet because vcpkg can't isntall to 
                                   # %APPDATA%\LV2 or %COMMONPROGRAMFILES%\LV2 but also complains about dlls in "${CURRENT_PACKAGES_DIR}/lib/lv2"
        -Dvamp=disabled           # 'auto', 'disabled', 'enabled'
        -Dcmdline=${CLI_FEATURE}   # 'auto', 'disabled', 'enabled'
        -Dtests=disabled           # 'auto', 'disabled', 'enabled'
    )

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/rubberband-program${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
  # Rubberband uses a different executable name when compiled with msvc
  # Just looking for that file is faster than detecting msvc builds
  set(RUBBERBAND_PROGRAM_NAMES rubberband-program rubberband-program-r3)
else()
  set(RUBBERBAND_PROGRAM_NAMES rubberband rubberband-r3)
endif()

# Remove them when not enabled.
if("cli" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES ${RUBBERBAND_PROGRAM_NAMES} AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
