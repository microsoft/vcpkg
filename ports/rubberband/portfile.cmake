vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO breakfastquay/rubberband
    REF v3.1.1
    SHA512 aef4de02b6fe250ab43d627d30720dab8aea3587b428ce76fe339d0b1f0e50da6ba7fa7c76f61306704dd2cfc24241f3d4108b6c155c3d12624eac859672f86c
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
  set(RUBBERBAND_PROGRAM_NAMES rubberband-program rubberband-program-r3)
else()
  set(RUBBERBAND_PROGRAM_NAMES rubberband rubberband-r3)
endif()

# Features cli and lv2 are build whenever suficient dependencies are installed,
# Remove them when not enabled.
if("cli" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES ${RUBBERBAND_PROGRAM_NAMES} AUTO_CLEAN)
else()
  vcpkg_clean_executables_in_bin(FILE_NAMES ${RUBBERBAND_PROGRAM_NAMES})
endif()

# lv2 feature is not supported yet because vcpkg can't isntall to
# %APPDATA%\LV2 or %COMMONPROGRAMFILES%\LV2 but also complains about dlls in "${CURRENT_PACKAGES_DIR}/lib/lv2"
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/lv2" "${CURRENT_PACKAGES_DIR}/debug/lib/lv2")

file(
  INSTALL "${SOURCE_PATH}/COPYING"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)
