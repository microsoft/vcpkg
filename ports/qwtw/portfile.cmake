vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO ig-or/qwtw
   REF 7d6e7c95437cbc7d5d123fc1ccf0d6a3c4e419e6 # v3.1.0
   SHA512 de5abf26d0975b9f0ed88e10cd4d5b4d12e25cce8c87ab6a18d8e7064697de6fc8da83e118b5a4e2819c09e2dbbfd20daeecc6a42748c019c6699666276d075a
   HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
