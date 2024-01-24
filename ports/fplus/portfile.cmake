vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF "v${VERSION}"
    SHA512 399ff3012efd49e8617a0ae275e72bf13e87380e830f6ceb56f85fcda948d4ef252c5aa48f48f0a4a015874015d6e8ff442ac9395d523b4c946a01c17f2bd1b9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFunctionalPlus_INSTALL_CMAKEDIR=share/FunctionalPlus
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
