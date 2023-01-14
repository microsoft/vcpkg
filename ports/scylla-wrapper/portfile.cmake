# scylla_wrapper_dll supplies a DllMain
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cypherpunk/scylla_wrapper_dll
    REF 4ad953ec04108269f1d80a91b2723b3e22d1b4d2
    SHA512 d7cb72e097e86e96cf0a8f463c0f839c9608fa4276bc1e2e984290984bcfe8a5b2257b1511259cb78802819fadf2c1001dc3011ee2c6dc9dfcbdb561d34e0c35
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(REMOVE
    "${SOURCE_PATH}/scylla_wrapper_dll/distorm.h"
    "${SOURCE_PATH}/scylla_wrapper_dll/distorm_x64.lib"
    "${SOURCE_PATH}/scylla_wrapper_dll/distorm_x86.lib"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG 
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
