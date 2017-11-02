if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    message(STATUS "Warning: Dynamic building not supported yet. Building static.")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/bond-6.0.0)

vcpkg_download_distfile(ARCHIVE
  URLS "https://github.com/Microsoft/bond/archive/6.0.0.zip"
  FILENAME "bond-6.0.0.zip"
  SHA512 d585debabb7b74c1e85313278456bd6b63a388dbf64515c550b1d9739114b0963ffb1982d145fa4d3717747e8eba82e79ed2744a6c9e3cb1615d9a78b75b42bb
)
vcpkg_download_distfile(GBC_ARCHIVE
  URLS "https://github.com/Microsoft/bond/releases/download/6.0.0/gbc-6.0.0-amd64.exe.zip"
  FILENAME "gbc-6.0.0-amd64.zip"
  SHA512 2aa4b5add478b952cb7733dcbf5c35634cde66812f1f1920d5fb1e2a52681a101ac6157bdba535a59316c4590fa37c74889b734106ca3e202a7a5ec0bcb1847f
)

vcpkg_extract_source_archive(${ARCHIVE})

# Extract the precompiled gbc
vcpkg_extract_source_archive(${GBC_ARCHIVE} ${CURRENT_BUILDTREES_DIR}/tools/)
set(FETCHED_GBC_PATH ${CURRENT_BUILDTREES_DIR}/tools/gbc-6.0.0-amd64.exe)

if (NOT EXISTS "${FETCHED_GBC_PATH}")
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
