vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO emoon/minifb
    REF 2ce2449b1bc8d7c6d20c31b86244f1e540f2e788 # 2023-09-21
    SHA512 cbadc06df99f833fedcd9eb9d5afab4572272a9dfd0f4084a2b79a64dc98f19bcddbb6f43992b16f005d26054c454e3cfc34e3e210cdd93ad1adb89e19463a4d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMINIFB_BUILD_EXAMPLES=FALSE
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
