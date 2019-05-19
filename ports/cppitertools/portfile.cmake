# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ryanhaining/cppitertools
    REF 97bfd33cdc268426b20f189c13d3ed88f5e1f4c2
    SHA512 7b8926cf00b5be17fa89a1d1aea883e60848187bb00d637c40a20f6e11811add4785f2f461e530a6cd557d3be16490799ffcd7ea90bd7b58fdca549c3df03e8c
    HEAD_REF master
)

file(GLOB INCLUDE_FILES ${SOURCE_PATH}/*.hpp)
file(GLOB INCLUDE_INTERNAL_FILES ${SOURCE_PATH}/internal/*.hpp)

file(COPY ${INCLUDE_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(COPY ${INCLUDE_INTERNAL_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/internal)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
