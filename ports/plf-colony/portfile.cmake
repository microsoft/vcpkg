# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_colony
    REF 81fe8c4daf433491f14248837ee8ed5cf447c856
    SHA512 a6ae03d383c94b0a758e7aedee2838d46b3665881e2c0823b064a3579140a351d96fec66d456de5843b6c4c8d2f6f6efac5f547841c08edd349b0f153e9c4871
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_colony.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
