vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO deadlightreal/SwiftNet
    REF 1.0.0
    SHA512 a6e884768e5baabcdc9e1ffc977e0ea930cbeba659f4492a21010c205d2b015deaf6f27a77b48ce38b0d7c815f9098f235f4ada1c531abca2eec7729af559670
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/src
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
