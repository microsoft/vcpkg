vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO christophercrouzet/rexo
    REF fcfb35d341aa5c7921a1e9e3350d4768104617e0
    SHA512 9ab931c38c0d29a3c7fcb105bce9d4b9d47db08a13cd3fa6c7c7c4fac5bce94583dddb8480e423b80bd2e7191e0f73dbd3bfda62ca36cbd2c4ca164b7705fb6a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/rexo.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

configure_file(${SOURCE_PATH}/UNLICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
