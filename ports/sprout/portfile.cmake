# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bolero-MURAKAMI/Sprout
    REF 6b5addba9face0a6403e66e7db2aa94d87387f61
    SHA512 b81c299842c48626a7fbedb5b70932623ddb128bd5c71115269253b2c82a331d4f5d5adeab24529be2c886d293de96c15c9641280b4eb31bd60379b284556900
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/sprout DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE_1_0.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
