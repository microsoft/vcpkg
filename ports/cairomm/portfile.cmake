set(CAIROMM_VERSION 1.16.0)
set(CAIROMM_HASH 51929620feeac45377da5d486ea7a091bbd10ad8376fb16525328947b9e6ee740cdc8e8bd190a247b457cc9fec685a829c81de29b26cabaf95383ef04cce80d3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.cairographics.org/releases/cairomm-${CAIROMM_VERSION}.tar.xz"
    FILENAME "cairomm-${CAIROMM_VERSION}.tar.gz"
    SHA512 ${CAIROMM_HASH}
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    PATCHES
        undef.win32.patch # because WIN32 is used as an ENUM identifier. 
)

vcpkg_configure_meson(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dbuild-examples=false
        -Dmsvc14x-parallel-installable=false
)

vcpkg_install_meson()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

if(VCPKG_LIBRARY_LINAKGE STREQUAL "static")
    set(_file "${CURRENT_PACKAGES_DIR}/lib/cairomm-1.16/include/cairommconfig.h")
    if(EXISTS "${_file}")
        vcpkg_replace_string("${_file}" "# define CAIROMM_DLL 1" "# undef CAIROMM_DLL\n# define CAIROMM_STATIC_LIB 1")
    endif()
    set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/cairomm-1.16/include/cairommconfig.h")
    if(EXISTS "${_file}")
        vcpkg_replace_string("${_file}" "# define CAIROMM_DLL 1" "# undef CAIROMM_DLL\n# define CAIROMM_STATIC_LIB 1")
    endif()
endif()

# option('maintainer-mode', type: 'combo', choices: ['false', 'if-git-build', 'true'],
  # value: 'if-git-build', description: 'Let mm-common-get copy some files to untracked/')
# option('warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'],
  # value: 'min', description: 'Compiler warning level')
# option('dist-warnings', type: 'combo', choices: ['no', 'min', 'max', 'fatal'],
  # value: 'fatal', description: 'Compiler warning level when a tarball is created')
# option('build-deprecated-api', type: 'boolean', value: true,
  # description: 'Build deprecated API and include it in the library')
# option('build-exceptions-api', type: 'boolean', value: true,
  # description: 'Build exceptions API and include it in the library')
# option('build-documentation', type: 'combo', choices: ['false', 'if-maintainer-mode', 'true'],
  # value: 'if-maintainer-mode', description: 'Build and install the documentation')
# option('build-examples', type: 'boolean', value: true,
  # description: 'Build example programs')
# option('build-tests', type: 'combo', choices: ['false', 'if-dependencies-found', 'true'],
  # value: 'if-dependencies-found', description: 'Build test programs (requires Boost Test and Fontconfig or Windows)')
# option('boost-shared', type: 'boolean',
  # value: false, description: 'Use shared version of boost')
# option('msvc14x-parallel-installable', type: 'boolean', value: true,
  # description: 'Use separate DLL and LIB filenames for Visual Studio 2017 and 2019')