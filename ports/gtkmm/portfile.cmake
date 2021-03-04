if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL WindowsStore)
    message(FATAL_ERROR "Error: UWP builds are currently not supported.")
endif()

vcpkg_download_distfile(ARCHIVE
    URLS "https://ftp.gnome.org/pub/GNOME/sources/gtkmm/4.0/gtkmm-4.0.0.tar.xz"
    FILENAME "gtkmm-4.0.0.tar.xz"
    SHA512 16893b6caa39f1b65a4140296d8d25c0d5e5f8a6ab808086783e7222bc1f5e8b94d17d48e4b718a12f0e0291010d445f4da9f88b7f494ec36adb22752d932743
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES build.patch
            gtkapi.patch    #upstream patch to fix dllimport issue
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -Dmsvc14x-parallel-installable=false
        -Dbuild-tests=false
        -Dbuild-demos=false
    ADDITIONAL_NATIVE_BINARIES glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
    ADDITIONAL_CROSS_BINARIES  glib-compile-resources='${CURRENT_HOST_INSTALLED_DIR}/tools/glib/glib-compile-resources${VCPKG_HOST_EXECUTABLE_SUFFIX}'
)

vcpkg_install_meson()

vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()


file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/gtkmm" RENAME copyright)


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
# option('build-demos', type: 'boolean', value: true, description: 'Build demo programs')
# option('build-tests', type: 'boolean', value: true, description: 'Build test programs')
# option('msvc14x-parallel-installable', type: 'boolean', value: true,
  # description: 'Use separate DLL and LIB filenames for Visual Studio 2017 and 2019')
