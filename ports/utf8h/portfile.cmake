# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sheredom/utf8.h
    REF 841cb2deb8eb806e73fff0e1f43a11fca4f5da45
    SHA512 cce44011abc58556c031c0de1018b83225bdbbc0e8d7374e3fd6f0b63c8e200086c49e7caac61b559f1e6d5a7ad349a58a13876a1b1341c18349a5cee59a105b
    HEAD_REF master
)

# Copy the utf8h header files
file(COPY ${SOURCE_PATH}/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/utf8h)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/utf8h RENAME copyright)