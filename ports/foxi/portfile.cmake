vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO houseroad/foxi
    REF c278588e34e535f0bb8f00df3880d26928038cad
    SHA512 ad42cfd70e40ba0f0a9187b34ae9e3bd361c8c0038669f4c1591c4f7421d12ad93f76f42b33c2575eea1a3ddb3ff781da2895cdc636df5b60422598f450203c7
    PATCHES
        remove-test-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
