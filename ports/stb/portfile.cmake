#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nothings/stb
    REF 9d9f75eb682dd98b34de08bb5c489c6c561c9fa6
    SHA512 e710385b1de9b07108c1a0628e74832e163729d95d529a6fe333156cc8e518af47e480761c2f9acd69cffbc14e477952d7e5b208708ffbd3870949dccf315b4f
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/stb/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/stb/README.md ${CURRENT_PACKAGES_DIR}/share/stb/copyright)

# Copy the stb header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
