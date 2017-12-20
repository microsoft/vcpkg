if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-7.0.2)

vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/Microsoft/bond/archive/7.0.2.zip"
  FILENAME "bond-7.0.2.zip"
  SHA512 4ae3b88fafbede6c1433d171713bdbfcbed61a3d2a983d7df4e33af893a50f233be0e95c1ea8e5f30dafb017b2a8100a23721292b04184159e5fd796b1a43398
)
vcpkg_download_distfile(GBC_ARCHIVE
  URLS "https://github.com/Microsoft/bond/releases/download/7.0.2/gbc-7.0.2-amd64.exe.zip"
  FILENAME "gbc-7.0.2-amd64.exe.zip"
  SHA512 069eafd7641ebd719425037cb8249d2d214eb09c6ce38fbf1d1811c01d1839b0a0987c55217075b6ae9f477f750d582250134387a530edb2aee407b21d973915
)

vcpkg_extract_source_archive(${ARCHIVE})

# Extract the precompiled gbc
vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc-7.0.2-amd64.exe)

if (NOT EXISTS "${FETCHED_GBC_PATH}")
    message(FATAL_ERROR "Fetching GBC failed. Expected '${FETCHED_GBC_PATH}' to exists, but it doesn't.")
endif()

vcpkg_apply_patches(
  SOURCE_PATH ${SOURCE_PATH}
  PATCHES
    # Don't install rapidjson from the (empty) submodule. With vcpkg, we get
    # rapidjson from vcpkg
    ${CMAKE_CURRENT_LIST_DIR}/0002_omit_rapidjson.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DBOND_LIBRARIES_ONLY=TRUE
    -DBOND_GBC_PATH=${FETCHED_GBC_PATH}
    -DBOND_ENABLE_COMM=FALSE
    -DBOND_ENABLE_GRPC=FALSE
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
