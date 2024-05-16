vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO qicosmos/cinatra
    REF ${VERSION}
    SHA512 55bba51bb6190b76bc6415d3c36e82daeb5f174f1cb10490951cf05863f55653a6d68ffd3b66c5b3b2ebb6e68a7a84c090e973a6718f3f2a5849b04330e4b180
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_UNIT_TESTS=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_PRESS_TOOL=ON
)

vcpkg_cmake_install()


# Copy the entire include directory
file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR})

# Copy executables to the tools directory
if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/cinatra_example.exe")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/cinatra_example.exe"
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cinatra")
    file(COPY "${CURRENT_PACKAGES_DIR}/bin/cinatra_press_tool.exe"
         DESTINATION "${CURRENT_PACKAGES_DIR}/tools/cinatra")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
vcpkg_copy_pdbs()

# Cleanup unwanted directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${SOURCE_PATH}/.git")

