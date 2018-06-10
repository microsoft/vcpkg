#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyobjloader
    REF 8fd9f6e57bf8c70d5ae47cf0f0d1bf1ccae2dfc2
    SHA512 5b6a2822989c5a28eabee0a33724c045b5d07cf0ccfd4288c7c3a5a2cc5b0c3f6ee8aca45e8e22c941278fbbfabd8f909f5010cd34b9d905c4d84102d151c73b
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/README.md ${CURRENT_PACKAGES_DIR}/share/tinyobjloader/copyright)

# Copy the tinyobjloader header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)