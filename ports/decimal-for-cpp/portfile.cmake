vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpiotr/decimal_for_cpp
    REF 375633343aa0af812a3ebf4bd06adaeff112ead4
    SHA512 7692fbb1643ed77b0b44fee1cf9a603fa257a5cf64ea66193c571fca61d138c6465a359db21955a4e2a234677f1806d47e05811daf2954004b108e09d3c8d4fa
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/include/decimal.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/decimal-for-cpp)
file(COPY ${SOURCE_PATH}/doc/license.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/license.txt ${CURRENT_PACKAGES_DIR}/share/decimal-for-cpp/copyright)
