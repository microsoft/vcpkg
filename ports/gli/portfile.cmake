#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/gli
    REF dd17acf9cc7fc6e6abe9f9ec69949eeeee1ccd82
    SHA512 9e3a4ab9ee73d5c271b8346cf81339cd3cd0c20d20991524b816313b6a99e8d3a01863316a38cf1a52ef9c5b31d689ecccf6248b12d1d270460c048bf904650b
    HEAD_REF master
)

# Put the license file where vcpkg expects it
# manual.md contains the "licenses" section for the project
file(COPY ${SOURCE_PATH}/manual.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/gli/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/gli/manual.md ${CURRENT_PACKAGES_DIR}/share/gli/copyright)

# Copy the glm header files
file(GLOB HEADER_FILES "${SOURCE_PATH}/gli/*.hpp" "${SOURCE_PATH}/gli/core")
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/gli)
