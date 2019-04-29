include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CaptainCrowbar/unicorn-lib
    REF 4b6901e0e5a3099a2dd2c44f8dd6f20f2e1a14cb
    SHA512 92e3c592bfba004d551acef9e54e5b2c7e442534851c0b08b8d9e990474d9dca5ab5d738e84e1cdfc98f888ebbbb5bf7032041f8488f4dba4fd32e76639f48d7
    HEAD_REF master
)

file(COPY ${CURRENT_PORT_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DUNICORN_LIB_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.TXT DESTINATION ${CURRENT_PACKAGES_DIR}/share/unicorn-lib RENAME copyright)