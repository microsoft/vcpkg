include(vcpkg_common_functions)


vcpkg_download_distfile(
    PATCH_FILE_PATH
    URLS https://patch-diff.githubusercontent.com/raw/ivmai/bdwgc/pull/281.diff
    FILENAME "install-cmake.diff"
    SHA512 e94343f77f0e83816c215a9c7b572fcbed57a162b5c20ccf87e2169013aedd8041748be700959184aab6e11e54fad817fe8545d25cda22f7e966dc5542bb92d0
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ivmai/bdwgc
    # REF v8.0.4
    # SHA512 f3c178c9cab9d9df9ecdad5ac5661c916518d29b0eaca24efe569cb757c386c118ad4389851107597d99ff1bbe99b46383cce73dfd01be983196aa57c9626a4a
    REF 2b7003769e1ecc941ef80b603cba16a121f37997
    SHA512 ef2438780cd2bc0d938663c75244dc876aeacb5e1b1c5d30a46c4710608505481ff9769fe9ab142fa03c494ec1853333c873c8a89354b3b363279ed8b8cb1b2a
    HEAD_REF master
    PATCHES
        ${PATCH_FILE_PATH} # 001-install-libraries.patch 
)


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -Dinstall_tests=OFF
        -Dinstall_cord=OFF
    OPTIONS_DEBUG 
        -Dinstall_headers=OFF 
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/README.QUICK DESTINATION ${CURRENT_PACKAGES_DIR}/share/bdwgc RENAME copyright)
