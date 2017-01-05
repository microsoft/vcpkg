# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/lua-intf-efac2178966c4937043b2ff346e67cd88d90dbee)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/SteveKChiu/lua-intf/archive/efac2178966c4937043b2ff346e67cd88d90dbee.zip"
    FILENAME "lua-intf-efac2178966c4937043b2ff346e67cd88d90dbee.zip"
    SHA512 be7f08aa4c83f9d22dc76f4db01abf6e1b128c28d41b4479e8a05ce1845f0b25268722bc35b799838c98bcc5286abe0e5ebf28065a90279fd0f37543bfc68d00
)
vcpkg_extract_source_archive(${ARCHIVE})

# Copy the header files
file(COPY ${SOURCE_PATH}/LuaIntf DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/lua-intf RENAME copyright)


