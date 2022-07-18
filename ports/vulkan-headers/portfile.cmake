# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/Vulkan-Headers
    REF 9f73b931f402f23554a60015924e7e35c7047487 #v1.3.221
    SHA512 4d566ea02ec9c20310a90fbef09ee1550ba3b0cd02db540733d985e83b07b8da3b46ec16c3cdddba5c057511bedd5efbf9514e3e6ed8f31520ee4fc6a40868bb
    HEAD_REF master
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
