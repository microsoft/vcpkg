vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge1/ELFIO
    REF Release_3.11
    SHA512 3a254aad62e707f2809e2997998aab6a9794d70791dc535a6de90bad3e9de3cbcc4f8e7787067ca7cd47ce2dc71cf52809747267bc36cfb08369b49a6b92cf5e)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
