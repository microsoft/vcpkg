vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 09663ab9a9dcdedea0656c7ac1fbb062af2e7ce6b0e6cfb978dde376efaded22a97aadead9083212fdaea60d78021d870767f642de305209ebd0e445b412cef7
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
