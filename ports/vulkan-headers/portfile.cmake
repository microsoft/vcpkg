vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 2bb0a23104ceffd9a28d5b7401f2cee7dae35bb8
    SHA512 06eaf7cddf2d8c9487244f3c3adee0a2ebed7f8d53a34409cc19d91847e9b5110cbd9af6b71379ae3e4c310db341cff38fc6978af713aa000e6789f1afec4b03
    HEAD_REF v1.3.239
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
