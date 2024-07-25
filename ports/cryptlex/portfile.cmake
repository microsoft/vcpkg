# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL git@github.com:Intelight/cryptlex.git
    REF e6c13c706c3e1d6c6e19515820069a61f54de4f3
    HEAD_REF main
)

# Copy the header files
file(COPY ${SOURCE_PATH}/windows/include DESTINATION ${CURRENT_PACKAGES_DIR}/)
file(COPY ${SOURCE_PATH}/windows/lib/x64_MT/static/LexActivator.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
file(COPY ${SOURCE_PATH}/windows/lib/x64_MT/static/LexActivatord.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/cryptlex RENAME copyright)

