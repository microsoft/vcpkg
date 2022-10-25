vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tfhe/tfhe
    REF v1.0.1
    SHA512 1d625eb00bf6a36fd86cfad8e1763d7030dd73d68f2422d1678f51352708e9275f0ce69c23fb0d9fec30fba00e1ca4a3df29fb4fc6dfe3b7f16e0d350aa7f170
    HEAD_REF master
    PATCHES
        mac-fix.patch
)

# Workaround for https://github.com/tfhe/tfhe/issues/246
vcpkg_replace_string("${SOURCE_PATH}/src/CMakeLists.txt" "-Wall -Werror" "")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/src
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
