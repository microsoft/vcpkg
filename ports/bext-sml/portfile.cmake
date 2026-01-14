# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boost-ext/sml
    REF "v${VERSION}"
    SHA512 3f49c1e0f58a1e294fcea148fd268e2dfb8d4b527e3239f02718a2bfd27059d2b101d7e48878e4bfae49cc9c2a434de53b4c900fc5daf963512002017a3dffbd
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/boost/sml.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/boost"
)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
