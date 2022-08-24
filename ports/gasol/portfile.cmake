vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PytLab/GASol
    REF 05af009bca2903c1cc491c9a6eed01bc3c936637
    SHA512 a8546bf565a389b919dd1dd5b88b4985c1803cbb09fab0715d1b0abfda92a6bf3adea7e4b3329ad82a6f6892f1747a73a632687fd79fb77c937e7ba07c62268a
    HEAD_REF master
    PATCHES
       gasol.patch
       fix-install.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
