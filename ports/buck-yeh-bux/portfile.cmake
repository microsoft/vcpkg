vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO buck-yeh/bux
    REF "${VERSION}"
    SHA512 e7bd58955cded6d4977476a26c7a2d76601d2e52d0e058d968eef92cc3b27dbff1d60ce339280209f1f1e093c6d4b841e1e69b3add0c864a1b4d03cbb38083d2
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
