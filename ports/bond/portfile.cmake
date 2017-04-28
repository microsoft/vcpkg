if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-5.3.1)

vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/Microsoft/bond/archive/5.3.1.zip"
  FILENAME "bond-5.3.1.zip"
  SHA512 aa1b3b6cbbbfbdb450306b59d0216c4b63b25ce2f5852387b42cb5c098e8fb6f90d8d1f688344fa4375244510009767d7d46a6a0b5f49c725b22cf3e9d73d1e5
)
vcpkg_download_distfile(GBC_ARCHIVE
  URLS "https://github.com/Microsoft/bond/releases/download/5.3.1/gbc-5.3.1-amd64.exe.zip"
  FILENAME "gbc-5.3.1-amd64.zip"
  SHA512 fb1eff0b7bd34cba26fa6a0ffeba7789cff55976e95a695aa2cf6ae60b5c4e8b0dd15f0d7968599bd5b17c9b8b325aa29e3e13aca4854ec38ed50253d67038e4
)

vcpkg_extract_source_archive(${ARCHIVE})

# Extract the precompiled gbc
vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc-5.3.1-amd64.exe)

if (NOT EXISTS ${FETCHED_GBC_PATH})
    message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exists, but it doesn't.")
endif()

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

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DBOND_LIBRARIES_ONLY=TRUE
    -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
)

vcpkg_install_cmake()

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/bond)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/bond/LICENSE ${CURRENT_PACKAGES_DIR}/share/bond/copyright)

# Drop a copy of gbc in tools/ so that it can be used
file(COPY ${CURRENT_PACKAGES_DIR}/bin/gbc.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools/)

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
