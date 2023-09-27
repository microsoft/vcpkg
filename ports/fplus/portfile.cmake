vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF "v${VERSION}"
    SHA512 0e3478400c1acc2fc34642784f8bb3eb0f79bc4c157a38fb39c9f05d8e4c47cc6c9da765f76350fd593517c3a2db2515161f6f3d6ff770f2ace2da2a99bb493d
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
