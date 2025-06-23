vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

# Use local source when developing overlay ports:
# set(SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}/../..")

# Use GitHub when submitting to vcpkg registry:
vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-source-patterns/collection
        REF "${VERSION}"
        SHA512 f3781cbb4e9e190df38c3fe7fa80ba69bf6f9dbafb158e0426dd4604f2f1ba794450679005a38d0f9f1dad0696e2f22b8b086b2d7d08a0f99bb4fd3b0f7ed5d8
        HEAD_REF main
)

# Configuration, build, install, and fix-up
vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()

vcpkg_cmake_config_fixup() # removes /debug/share

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include") # removes debug/include
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}") # usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE") # LICENSE
