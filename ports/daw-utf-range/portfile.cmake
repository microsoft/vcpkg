vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/utf_range
    REF 6069d058c48f7b98ee2999929c146eb60a3b1313
    SHA512 6a9f3abdf4c2b9569ebf3d5937a0671df33eaecc3cfc328c22dc0802a7f864f5556c50fcf31aea7e558025c801c8be693276106a7020fad951d52b67c8e5e7e5
    HEAD_REF master
    PATCHES my_utfcpp.patch
)

file(
    COPY 
        ${SOURCE_PATH}/include/utf8.h
        ${SOURCE_PATH}/include/utf8
        ${SOURCE_PATH}/include/daw/utf_range
    DESTINATION 
        ${CURRENT_PACKAGES_DIR}/include/daw
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
