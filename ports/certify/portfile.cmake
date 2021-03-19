# use https://github.com/djarek/certify if https://github.com/djarek/certify/pull/67 gets merged
# it fixes hostname verification
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jens-diewald/certify
    REF b09c57ef5f25f4276558376f9c5a02a57b9ded20
    SHA512 998e54fa4c63bb0743137a6f1d9e14c671d82db5bca6cbb1e693b369f348d0f974cdf9516b832ae6fc97164323e769cbe0b122d7938086f8e4d340afe6309890
    HEAD_REF hostname_verification
)

file(
    COPY ${SOURCE_PATH}/include/boost
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
