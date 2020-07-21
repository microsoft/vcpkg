vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO utfcpp/utf8cpp_2x
    REF Release%202.3.4
    FILENAME "utf8_v2_3_4.zip"
    SHA512 0e85e443e7bd4ecbe85dedfb7bdf8b1767808108b3a4fc1c0c508bcf74787539ae0af95a31a70e715ca872689ac4d7233afc075ceb375375d26743f92051e222
    NO_REMOVE_ONE_LEVEL
)

file(INSTALL ${SOURCE_PATH}/source/ DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL ${SOURCE_PATH}/source/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
