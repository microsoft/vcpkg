vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mraggi/discreture
    REF eeeec31c814e6a9a8506a6bfd6a5b35704350605
    SHA512 de1c7d74d337605fd9b9d1f3ee6637b4afd179d495de243b21168b0a4376b83c0519b4cced985af694850755ab1e3caca5087b3ca0cd6ccb3b73b10bd6b25b49
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)	
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
