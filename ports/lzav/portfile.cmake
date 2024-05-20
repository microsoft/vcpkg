vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 2e5c852dbace404816efc136b99a79f7e453347b0b641fa7f35da54d089f376f779fe9801265ce642c2d0dc4e5b222aa21f2a53277a4c5c78824f000ece25ed6
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
