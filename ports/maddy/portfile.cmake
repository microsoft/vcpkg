vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO progsource/maddy
    REF "${VERSION}"
    SHA512 702e37f7f249a96b1c57eb8986a40933b5bf40b473537d720affe8c7412ee7c4dea47b58681bf58e92b169803d35fb18f19fe0aad068757fc013fd672b0b0d15
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
