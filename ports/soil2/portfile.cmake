vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/soil2
    REF 51023d551d895fb4beb576d726d798ccfe358d34
    SHA512 5ce8b3f04eea674cdef7ee58778e81bcefa5df7afb1013ad28dcd2d502e26915529da8bf06b751b8c350165172866e4f99d4b1081bb6c7ba04ac83a78faba83c
    HEAD_REF master
)

file(
    COPY 
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    ${CMAKE_CURRENT_LIST_DIR}/soil2Config.cmake.in
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
