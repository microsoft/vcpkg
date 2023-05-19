vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lv2/sratom
    REF v0.6.4
    SHA512 c155694365e9efe2f108135cccafd6369e896bd27ec816ac8bb429785d9218b1b30e8532188cfb39485d4b163a920ddb47466a461dcd6958d754ed0698d31081
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()
file(
    INSTALL "${SOURCE_PATH}/COPYING"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)
