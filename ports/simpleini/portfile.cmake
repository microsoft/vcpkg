# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF 9b3ed7ec815997bc8c5b9edf140d6bde653e1458 #v4.19
    SHA512 80358c8e5b8d8ea6183c685d002378805450ee3d65599f5966c1c24c20869be4680b044a4443f00d64740e131d1c0efcdaaf0a53d5cbce26b185cdf946630d8a
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
