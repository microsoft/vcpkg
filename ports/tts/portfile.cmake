vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jfalcou/tts
    REF 2.1
    SHA512 d774073a91de26f7b0f2ceea25024ec2d8ca2cbbbdc1f82efa44df1ea11b8d9ae53ed4ceab974dcd0f50877a14fdbfb7172054646b24eb94952b4aa70de726f2
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/tts" RENAME copyright)
