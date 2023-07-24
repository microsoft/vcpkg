vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GPUOpen-LibrariesAndSDKs/VulkanMemoryAllocator
    REF 2a28bc4b39b9b80dad909036442f629f570d7ae1
    SHA512 cd83efc357171a5fd1ac65a566d1bf828f7de2b4c97adec92aaaf9cdfedf5a5525de3bd6eb84c453d1cd952c10c3542e6502ad4307a55b61690ce92b80dc4e2f
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
