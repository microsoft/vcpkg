include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/LuaBridge
    REF 2.3.1
    SHA512 6478410ec5863f40087f023a68c585b4c84974aa27dd522552094f6c823bee9820edc77685a9932b5d7d74f26cced4d624810dbfbaa3694f55c0b7803d2d5216
    HEAD_REF master
)

file(
    COPY ${SOURCE_PATH}/Source/LuaBridge
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

# Handle copyright
configure_file(
    ${SOURCE_PATH}/README.md
    ${CURRENT_PACKAGES_DIR}/share/luabridge/copyright
    COPYONLY
)
