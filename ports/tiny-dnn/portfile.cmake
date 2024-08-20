#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tiny-dnn/tiny-dnn
    REF c0f576f5cb7b35893f62127cb7aec18f77a3bcc5
    SHA512 f2bdf8a39781e0b2e3383d9e7a4a92daa28ee32e6f390c3fb21e9b24a597a50a8ccc4b5be345c433943db4db70fd2df8922ce3f13a792a4e73cd1fdd35842acf
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tiny_dnn DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/tiny-dnn)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/LICENSE ${CURRENT_PACKAGES_DIR}/share/tiny-dnn/copyright)
