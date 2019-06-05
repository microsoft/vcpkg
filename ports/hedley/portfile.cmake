# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/hedley
    REF 1b74d9bc892137b3f006d04ff905098b900116d0
    SHA512 8f3e4fc081fb33cc3a3d637eb09863e80fa94b5e46ecf6507aabe6a5b0648881a96c8cf2ef01b4146ecd3a14908ef87f3204960514af6c91d00c93bea18eda41
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/hedley.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${CMAKE_CURRENT_LIST_DIR}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
