vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpiotr/decimal_for_cpp
    REF 98265a57385ec14ae84fc0b2b0f15c770b30f548
    SHA512 b8779ffb81567309ab07fa17eb6d3eb8bb94f77f5a388fd395433a304923ccf75e753a5822f36e5ad9d8959ee1a92b660639367d3a443f353e3e22d36a056f4d
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/decimal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/decimal-for-cpp)
file(COPY ${SOURCE_PATH}/doc/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/license.txt ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/copyright)
