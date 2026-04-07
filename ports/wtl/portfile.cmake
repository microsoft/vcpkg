vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wtl/WTL%2010
    REF WTL%2010.0.10320%20Release
    FILENAME "WTL10_10320_Release.zip"
    NO_REMOVE_ONE_LEVEL
    SHA512 086a6cf6a49a4318a8c519136ba6019ded7aa7f2c1d85f78c30b21183654537b3428a400a64fcdacba3a7a10a9ef05137b6f2119f59594da300d55f9ebfb1309
    PATCHES
        # WTL 10 post-release updates; see
        # https://sourceforge.net/projects/wtl/files/WTL%2010/WTL10%20Post-Release%20Updates.txt/download
        appwizard_setup.js-vs2022.patch
        atlmisc.h-bug329.patch
        atlribbon.h-wtl66.patch
)

file(INSTALL "${SOURCE_PATH}/Include/" DESTINATION "${CURRENT_PACKAGES_DIR}/include" FILES_MATCHING PATTERN "*.h")
file(COPY "${SOURCE_PATH}/Samples" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${SOURCE_PATH}/AppWizard" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(INSTALL "${SOURCE_PATH}/MS-PL.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
