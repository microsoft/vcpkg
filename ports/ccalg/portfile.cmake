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
    SHA512 78f7112a81099fcce8f8ac03a4947be1e378c0e744e257a0b310ee6ae4dc3178f047e9f945199aa11b44949f25de08dd228e706e3e3b32d5af8300a9e78ec8e6
    HEAD_REF master
    PATCHES
        disable-testing.patch
)

# ccalg is header-only — CMake installs headers to include/ccalg/
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# Strip files installed by upstream CMakeLists.txt that vcpkg doesn't expect:
# - share/doc/ccalg/{LICENSE,README.md} (we handle license below)
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/share/doc"
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

# License
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Usage
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
