vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO imakris/mexce
    REF "v${VERSION}"
    SHA512 9ca7cc69a4fff5735c66c5976c4ce40b441110212928fa2a768d351f60278e2ad3f6e8e116a1c1a07b028742d8059ab8a5193494404f66e75319d9d82ca972bc
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/mexce.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
