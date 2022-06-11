vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO saucer/saucer
    REF 02029722d7c501c529a885c0a53211dd15d4f758
    SHA512 b3719d25301a3a9337ec255dc85b350cd25773876e8b24e258b90a9c49b8ac11c7c2e6b8fd51590c4c5ce65601a3a5556d042e8b3945069c2585057f55470a00
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH} 
    OPTIONS -Dsaucer_prefer_remote=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
