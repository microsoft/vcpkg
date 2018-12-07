include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF 9183f81cbb5bfb1fe3eeb4e38d1993a858a58744
    SHA512 6b25223bd07c46ff6f6ee239c794bf4b4a8b97430d85ad434eff80da3bf9692a5f47d428929efcba17f4392eb87c86c27e2fd6bf8d216ecd7c690dcf8cd4fad4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-lambda-cpp RENAME copyright)

