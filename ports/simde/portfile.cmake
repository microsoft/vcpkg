# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simd-everywhere/simde
    REF "v${VERSION}"
    SHA512 de17fca563c4db6766881e1c73142ad129a57febe55fa8ea1ae780226e60a84891b13d387e75574f2722d77e4013176e3c7dfaf17bccd8682b7d3d3ec8e92a54
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/simde" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
