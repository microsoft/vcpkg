# vcpkg portfile for ccalg
#
# Usage as overlay port:
#   vcpkg install ccalg --overlay-ports=<path-to-ccalg>/ports
#
# Submit to official registry:
#   After tagging a release (e.g. v0.1.0):
#   1. Update REF below to "v${VERSION}"
#   2. Compute SHA512 with:
#      curl -sL https://github.com/CandyMi/ccalg/archive/refs/tags/v0.1.0.tar.gz | sha512sum
#   3. Copy to vcpkg/ports/ccalg/ and submit PR

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CandyMi/ccalg
    REF "v${VERSION}"
    SHA512 19e8815902f1aef659155fb71863c6f95cf6f408195aacf057398b63d157dcff62904f34c199c57b1f482478f7a6e80944311e01add19529ca02eeddcfe663a5
    HEAD_REF master
    PATCHES
)

# ccalg is header-only — CMake installs headers to include/ccalg/
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

# Install usage file
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Remove debug (header-only, nothing to debug)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Usage header
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "\
ccalg is header-only. Include the relevant header(s) in your source:\n\
  #include <ccalg/ccmap.h>\n\
  #include <ccalg/cchashmap.h>\n\
  #include <ccalg/cclink.h>\n\
  #include <ccalg/cclist.h>\n\
  #include <ccalg/ccheap.h>\n\
  #include <ccalg/ccvector.h>\n\
  #include <ccalg/ccflatmap.h>\n\
  #include <ccalg/cctreap.h>\n\
")

vcpkg_copy_pdbs()
