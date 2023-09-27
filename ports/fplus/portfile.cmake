vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF "v${VERSION}"
    SHA512 
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
