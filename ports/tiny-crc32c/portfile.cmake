vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO AndyTechnologies/tiny-crc32c
	REF v1.0.1
    SHA512 35a818ba7b66c57e489a1aef885d2f96336a09f40c65e742d9d91ef6e195913632dec9624b40a3a86f14486fdcefd90ff0c12e1c9953f346032100a5f7c172a6
    HEAD_REF main
)

file(INSTALL
    "${SOURCE_PATH}/include/tiny_crc32c.hpp"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)
