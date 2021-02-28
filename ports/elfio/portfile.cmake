vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO serge1/ELFIO
    REF Release_3.8
    SHA512 befaa793301750d8de3decf138dfac2003fea36028f509959a96ed710e82e679ffd57370666996c4ee932d0c86f8be0d05d12a1ab78850ef26d1cc4d39b9b039)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/${PORT}/cmake)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
