if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-5.2.0)
vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/Microsoft/bond/archive/5.2.0.zip"
  FILENAME "bond-5.2.0.zip"
  SHA512  bc533d9e7431d0690b555aa4a42ca947f8025fc388f698c40cfeacf4286892ac5fd86d93df187009d4791e3eae240eb60886947cfe600838c6058274eb4d625c
  )

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
    # Change Boost_USE_STATIC_LIBS to be compatible with vcpkg's treatment
    # of Boost
    ${CMAKE_CURRENT_LIST_DIR}/0001_boost_static_libs.patch
    # Don't install rapidjson from the (empty) submodule. With vcpkg, we get
    # rapidjson from vcpkg
    ${CMAKE_CURRENT_LIST_DIR}/0002_omit_rapidjson.patch
)

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
# the output. Just delete the bin/ directories for now.
file(REMOVE_RECURSE
  ${CURRENT_PACKAGES_DIR}/bin/
  ${CURRENT_PACKAGES_DIR}/debug/bin/)

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
