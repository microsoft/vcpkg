# header-only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO syoyo/tinyexr
    REF d16ea6347ae78bcee984fb57cab1f023aeda4fb0
    SHA512 63399688d7894f9ac4b893b2142202b36108b5029b11c40c3f9ad0f0135625fb0c8e0d54cec88d92c016774648dc829a946d9575c5f19afea56542c00759546e
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/tinyexr.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(COPY ${CMAKE_CURRENT_LIST_DIR}/copyright DESTINATION ${CURRENT_PACKAGES_DIR}/share/tinyexr)
