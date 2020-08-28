#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yinqiwen/pbjson
    REF v1.0
    SHA512 ef84dcd764eb9edfef69f279d020aeff93edf906015c20df0b2528091533d7263221605583a738022db39724ec38f545feca68acc97462a855a7d8d7d461c56a
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/src/*.h  ${SOURCE_PATH}/src/*.hpp)

file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/pbjson)
