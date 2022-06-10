vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO breakfastquay/rubberband
    REF v2.0.2
    SHA512 56e33f3a6f5755242e46f9cb224e372bea7a367756f08d3322c8951a40b3907f1a2957775de6f2584a093e6adf82ca91015119650d5a624afe39086a47843ddc
    HEAD_REF default
)

vcpkg_configure_meson(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dfft=fftw                 # 'auto', 'builtin', 'kissfft', 'fftw', 'vdsp', 'ipp' 'FFT library to use. The default (auto) will use vDSP if available, the builtin implementation otherwise.')
        -Dresampler=libsamplerate  # 'auto', 'builtin', 'libsamplerate', 'speex', 'ipp' 'Resampler library to use. The default (auto) simply uses the builtin implementation.'
        -Dipp_path=                # 'Path to Intel IPP libraries, if selected for any of the other options.'
        -Dextra_include_dirs=      # 'Additional local header directories to search for dependencies.'
        -Dextra_lib_dirs=          # 'Additional local library directories to search for dependencies.'
    )

vcpkg_install_meson()

vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/rubberband-program${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
  # Rubberband uses a different executable name when compiled with msvc 
  # Just looking for that file is faster than detecting msvc builds
  set(RUBBERBAND_PROGRAM_NAME rubberband-program)
else()
  set(RUBBERBAND_PROGRAM_NAME rubberband)
endif()   

# Features cli and lv2 are build whenever suficient dependencies are installed,
# Remove them when not enabled. 
if("cli" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES "${RUBBERBAND_PROGRAM_NAME}" AUTO_CLEAN)
else()
  vcpkg_clean_executables_in_bin(FILE_NAMES "${RUBBERBAND_PROGRAM_NAME}")
endif()

# lv2 feature is not supported yet because vcpkg can't isntall to 
# %APPDATA%\LV2 or %COMMONPROGRAMFILES%\LV2 but also complains about dlls in "${CURRENT_PACKAGES_DIR}/lib/lv2"
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/lv2" "${CURRENT_PACKAGES_DIR}/debug/lib/lv2")

file(
  INSTALL "${SOURCE_PATH}/COPYING"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)
