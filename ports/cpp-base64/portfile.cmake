vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ReneNyffenegger/cpp-base64
    REF a8aae956a2f07df9aac25b064cf4cd92d56aac45 #Commits on Jun 19, 2019
    SHA512 cb8d8991b87bd70f6287fb2abe20cb2156a511fdccd42bb3fc441d81cccd55755a44579227d326585b8c7a514d9cfebda98a72801ea2a3019a935d52cb14fc90
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/base64.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(COPY ${SOURCE_PATH}/base64.cpp DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)