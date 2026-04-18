# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ez8-co/yapi
    REF a700188cc4cbbc48b3da8254ec5d433a1de47fb4
    SHA512 863b9e82d06a53332efc5c5d5a4b984a132102b97f2ddd53fe47d356be851577b73dbac51169eb3c4c9e3e52318847ec9ba96a8f5354dd24f37c87e704c77158
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/yapi.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
