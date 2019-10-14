# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rigtorp/SPSCQueue
    REF 5165a08ac4474c77c636050332eca6ebfdd53533
    SHA512 30cd60711f816e6003a5b114c48bd12da449cb7b0f19aa58dd57e3abc3e5200847c3eb492627b4013f57eec11d5d6f0a11fedbcb21dd8dd5c44682c49456e4e1
    HEAD_REF master
)

file(COPY
    ${SOURCE_PATH}/include/rigtorp/SPSCQueue.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include/rigtorp
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
