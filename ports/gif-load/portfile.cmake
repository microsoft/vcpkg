vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hidefromkgb/gif_load
    REF 74b674de2704bc1b20fc3bf482a5ee3e774b67c5
    SHA512 f58b02ad62c0898865bb0c933711f52eb203c3e49b832847613a1de32330192636ddd31aacba2cefe7a7acde7c9be3c5edeea262b905b9a49bf05f4bbafddc21
    HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/gif_load.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-gif-load-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-gif-load")

file(WRITE "${SOURCE_PATH}/UNLICENSE" [[This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
]])
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/UNLICENSE")
