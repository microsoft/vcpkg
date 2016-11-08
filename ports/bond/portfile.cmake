if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-53ea13692925bee4ba494ee9de3614f15c09d85d)
vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/Microsoft/bond/archive/53ea13692925bee4ba494ee9de3614f15c09d85d.zip"
  FILENAME "bond-5.0.0-4-g53ea136.zip"
  SHA512  fe39dc211f6b99cba3f2284d78a524305dfb8dcd1f597639c45625df369f96c3321cb6782fef9eb34d34fab69c8da9015024eee34be6d0a76d730729517183da
)
vcpkg_extract_source_archive(${ARCHIVE})

# To build Bond, you'll either need to have the Haskell toolchain installed
# or set the environment variable BOND_GBC_PATH to point to a directory that
# contains a pre-compiled version of gbc.exe.
#
# You can get a pre-compiled version of gbc from the Bond.Compiler NuGet
# package <http://www.nuget.org/packages/Bond.Compiler/>.
#
# For instructions on installing the Haskell toolchain and getting it to
# work with Bond, see the Bond README
# <https://github.com/Microsoft/bond/blob/master/README.md#windows>

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBOND_LIBRARIES_ONLY=TRUE
)

vcpkg_install_cmake()

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bond)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bond/LICENSE ${CURRENT_PACKAGES_DIR}/share/bond/copyright)

# vcpkg doesn't--as of version 0.0.30--like executables such as gbc.exe in
# the output. Just delete it for now.
file(REMOVE
  ${CURRENT_PACKAGES_DIR}/bin/gbc.exe
  ${CURRENT_PACKAGES_DIR}/debug/bin/gbc.exe)

# There's no way to supress installation of the headers in the debug build,
# so we just delete them.
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Bond's install target installs to lib/bond, but vcpkg expects the lib
# files to end up in lib/, so move them up a directory.
file(RENAME
  ${CURRENT_PACKAGES_DIR}/lib/bond/bond.lib
  ${CURRENT_PACKAGES_DIR}/lib/bond.lib)
file(RENAME
  ${CURRENT_PACKAGES_DIR}/lib/bond/bond_apply.lib
  ${CURRENT_PACKAGES_DIR}/lib/bond_apply.lib)
file(RENAME
  ${CURRENT_PACKAGES_DIR}/debug/lib/bond/bond.lib
  ${CURRENT_PACKAGES_DIR}/debug/lib/bond.lib)
file(RENAME
  ${CURRENT_PACKAGES_DIR}/debug/lib/bond/bond_apply.lib
  ${CURRENT_PACKAGES_DIR}/debug/lib/bond_apply.lib)

vcpkg_copy_pdbs()
