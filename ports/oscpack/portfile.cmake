if (VCPKG_TARGET_IS_WINDOWS)
    # This can (and should) be removed if oscpack ever supports dynamically linking on Windows
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RossBencina/oscpack
    REF release_1_1_0
    SHA512 7a61a364cab4914c81e113d7aeee2b4accf5e560f500df6634232e0093f564ed4bb0ef8e87d2c8a18f245b0c7ec25f41e64f42f20a6654c22bb5c02aa253bbd0
    PATCHES
      add-cmake-install-target.patch
      link-ws2_32-and-winmm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_build()

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" 
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

