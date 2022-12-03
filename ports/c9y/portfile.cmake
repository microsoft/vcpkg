vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rioki/c9y
    REF v0.5.0
    SHA512 596bf99e031a44997ab114831a720667d4988ff20af1abb43a17f92f18cf820dfe5f7ad8d91b6a77db2fa7d12b29bc5afd5fb6654381c2c687d8fecb297b32f6
    )

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
