vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            offscale/cauthflow
    REF             590f42693a3cee88edde14fb1be5554702794050
    SHA512          1c23663297fbe95f32a1c33bd17369afc0d383303446d3f3fbe4303b78848f451cdacfdbdf05123ca24cf628945a50b544fd6ff311ba302ecc11752a22c5dcd0
    HEAD_REF        master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/cmake/LICENSE.txt"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
     RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
