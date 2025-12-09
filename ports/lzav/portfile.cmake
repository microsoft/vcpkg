vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO avaneev/lzav
    REF ${VERSION}
    SHA512 efc46188614abc3f3660836113090095957dfef07cd27b30a32710dbdc6a023a2dfc5f417cb7056ad74de41c886d5ab449c746fb597f17e3e30c573103e469bf
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/lzav.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
