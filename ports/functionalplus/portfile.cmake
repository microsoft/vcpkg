set(VCPKG_BUILD_TYPE release)  # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Dobiasd/FunctionalPlus
    REF "v${VERSION}"
    SHA512 06eb3453cf2d1f8931223b8da9b6a5a6243cae99ce930b74cbd72a4e146eb10dc464f01021d5acbadfe75fe2d2b06580fbd3bb014792f000156ae05e5e3e3a64
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFunctionalPlus_INSTALL_CMAKEDIR=share/functionalplus
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
