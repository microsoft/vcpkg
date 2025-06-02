# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF "v${VERSION}"
    SHA512 6c198636816a0018adbf7f735d402c64245c6fcd540b7360d4388d46f007f3a520686cdaec4705cb8cb31401b2cb4797a80b42ea5d08a6a5807c0848386f7ca1
    HEAD_REF master
)

# Install codes
set(SIMPLEINI_SOURCE ${SOURCE_PATH}/SimpleIni.h
                     ${SOURCE_PATH}/ConvertUTF.h
                     ${SOURCE_PATH}/ConvertUTF.c
)

file(INSTALL ${SIMPLEINI_SOURCE} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# copyright
file(INSTALL "${SOURCE_PATH}/LICENCE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
