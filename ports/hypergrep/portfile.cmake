vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/hypergrep
    REF v0.1.1
    SHA512 22565b6763299b80edd6d80573b4cc2983668b65605caebb41d81349d4c8d7e245c1113c14bb2cd2e7174c629f490afa2e91e3bb6e8ded0177d91b617c3b3f7f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
