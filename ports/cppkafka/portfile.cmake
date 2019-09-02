include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mfontanini/cppkafka
    REF v0.3.1
    SHA512 60d01ce1dd9bd9119676be939ed5ab03539abb1f945c1b31e432edfe0f06542778f7fef37696f5ff19c53024f44d5cbd8aeddbbb231c38b098e05285d3ff0cab
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
       -DCPPKAFKA_DISABLE_TESTS=ON
       -DCPPKAFKA_DISABLE_EXAMPLES=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)