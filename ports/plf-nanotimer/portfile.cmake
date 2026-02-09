# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_nanotimer
    REF 344c8e6f87e2ee924e4b0ae7ed71803a0ce75981 # v1.0.8
    SHA512 11db9b5fb818ad639f6e9076aa29c322ae24d9b071e72df54086a30b77cca3c2020fcb5f120fa56ef7712a7e5ba1db63bc191648499bae87a1b662a076ca8d39
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_nanotimer.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
