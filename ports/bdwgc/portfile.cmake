vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    # REF v8.0.4
    # SHA512 f3c178c9cab9d9df9ecdad5ac5661c916518d29b0eaca24efe569cb757c386c118ad4389851107597d99ff1bbe99b46383cce73dfd01be983196aa57c9626a4a
    REF 0c8905e84d16bd5e14ed91e21904fd7ab9d197e2
    SHA512 b38fe86d0dfaacd502971e39ea7df83a3dbf5542711f6b0462b7a6d48dbcf43da07a41a60ee96bca6403a2d2adaac0815a64667f3c80549ca57c5ebbe0e9672d
    HEAD_REF master
    PATCHES
        001-install-libraries.patch 
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -Dbuild_tests=OFF
        -Dbuild_cord=OFF
    OPTIONS_DEBUG 
        -Dinstall_headers=OFF 
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.QUICK DESTINATION ${CURRENT_PACKAGES_DIR}/share/bdwgc RENAME copyright)
