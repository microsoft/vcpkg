# header only
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vinniefalco/Beast
    REF v1.0.0-b30
    SHA512 78b1b09d6785e8b782bea72b6849936c0be45df1fd137db832c0afe1b09af122e0fd69e25321bcd8681f03015d94345a40f9650a5560f12c73457e4cc82e2f30
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/beast RENAME copyright)