vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aantron/better-enums
    REF ${VERSION}
    SHA512 5997c74932803fb96beabbe029d80f6fdeab7c46f781a4e11ef775242d294dfd82ca05cac99787dd68a622db62510fd5533e9c0e85a62c7792c0dbe6237af6d9
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/enum.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/better-enums")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
