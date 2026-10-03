vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fcf-framework/fcfTest
    REF "v1.2.5"
    SHA512 c37e2dc7c2867e1d8d30f9b623c80c64476c7c26bbe0b0d82cfc140fcec9406549406843c73f7337786dc2f78ad59c7f8b8a15c18bbea8ff1329649b33bf192f
)

file(INSTALL "${SOURCE_PATH}/test.hpp" DESTINATION "${CURRENT_PACKAGES_DIR}/include/fcfTest")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

