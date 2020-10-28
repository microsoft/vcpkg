# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_stack
    REF 9d046154d8954eafc12f8d4845505beec8c4a5da
    SHA512 2202bbff0e93bf515ae7b237551d084dcba9b870bca82f49b4e1a64446f4574079b0cb45fb91f0ad0472e008f21ad014464b45e307ffa6dab19affc6dc38626a
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_stack.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
