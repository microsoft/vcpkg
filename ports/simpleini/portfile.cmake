# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brofield/simpleini
    REF "v${VERSION}"
    SHA512 b937c18a7b6277d77ca7ebfb216af4984810f77af4c32d101b7685369a4bd5eb61406223f82698e167e6311a728d07415ab59639fdf19eff71ad6dc2abfda989
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
