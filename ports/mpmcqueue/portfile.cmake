# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/MPMCQueue
    REF 5883e32b07e8a60c22d532d9120ea5c11348aea9
    SHA512 4adbbe5e014e0ef5c7030aaa9faa4e07e2c65753cd89c770da250811c13776576c4f1caf4144542318c41ebc7433b106e802c482a5d44572963a5ab59047257e
    HEAD_REF master
)

file(COPY
    ${SOURCE_PATH}/include/rigtorp/MPMCQueue.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/rigtorp
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
