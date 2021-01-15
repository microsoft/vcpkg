if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/atkmm/2.36/atkmm-2.36.0.tar.xz"
    FILENAME "atkmm-2.36.0.tar.xz"
    SHA512 8527dfa50191919a7dcf6db6699767352cb0dac800d834ee39ed21694eee3136a41a7532d600b8b3c0fcea52da6129b623e8e61ada728d806aa61fdc8dc8dedf
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        #fix_properties.patch
        #fix_charset.patch
)

# if (VCPKG_TARGET_IS_WINDOWS)
    # file(COPY ${CMAKE_CURRENT_LIST_DIR}/msvc_recommended_pragmas.h DESTINATION ${SOURCE_PATH}/MSVC_Net2013)

    # set(VS_PLATFORM ${VCPKG_TARGET_ARCHITECTURE})
    # if(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
        # set(VS_PLATFORM "Win32")
    # endif(${VCPKG_TARGET_ARCHITECTURE} STREQUAL x86)
    # vcpkg_build_msbuild(
        # PROJECT_PATH ${SOURCE_PATH}/MSVC_Net2013/atkmm.sln
        # TARGET atkmm
        # PLATFORM ${VS_PLATFORM}
        # USE_VCPKG_INTEGRATION
    # )

    # # Handle headers
    # file(COPY ${SOURCE_PATH}/MSVC_Net2013/atkmm/atkmmconfig.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    # file(COPY ${SOURCE_PATH}/atk/atkmm.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)
    # file(COPY ${SOURCE_PATH}/atk/atkmm
        # DESTINATION ${CURRENT_PACKAGES_DIR}/include
        # FILES_MATCHING PATTERN *.h)

    # # Handle libraries
    # file(COPY ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/atkmm.dll
        # DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    # file(COPY ${SOURCE_PATH}/MSVC_Net2013/Release/${VS_PLATFORM}/bin/atkmm.lib
        # DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    # file(COPY ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/atkmm.dll
        # DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    # file(COPY ${SOURCE_PATH}/MSVC_Net2013/Debug/${VS_PLATFORM}/bin/atkmm.lib
        # DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

    # vcpkg_copy_pdbs()
# else()

vcpkg_configure_meson(SOURCE_PATH ${SOURCE_PATH} 
                      OPTIONS -Dbuild-documentation=false
                              -Dmsvc14x-parallel-installable=false)
vcpkg_install_meson()
# endif()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")


# option('maintainer-mode', type: 'combo', choices: ['false', 'if-git-build', 'true'],
  # value: 'if-git-build', description: 'Generate source code from .hg and .ccg files')
# option('warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'], value: 'min',
  # description: 'Compiler warning level')
# option('dist-warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'], value: 'fatal',
  # description: 'Compiler warning level when a tarball is created')
# option('build-deprecated-api', type: 'boolean', value: true,
  # description: 'Build deprecated API and include it in the library')
# option('build-documentation', type: 'combo', choices: ['false', 'if-maintainer-mode', 'true'],
  # value: 'if-maintainer-mode', description: 'Build and install the documentation')
# option('msvc14x-parallel-installable', type: 'boolean', value: true,
  # description: 'Use separate DLL and LIB filenames for Visual Studio 2017 and 2019')
