include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-libs/gherkin-c
    REF 8f31c2ff6a7b58196a061c8847508563679f67b3
    SHA512 f78a1f9da7ff38fe2546e0db9ed33a2e25e12aa8a407ce827933a379ce083e6f872b39eb2321ff8c35199015c3c2299e46567171c5edfeff07600765f3f0a6ec
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_GHERKIN_TESTS=OFF
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gherkin-c RENAME copyright)
