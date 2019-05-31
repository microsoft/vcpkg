# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.2.13
    SHA512 5c508a1f43d2ca86c89b9aac3b17493a23b8ee3c7485438afc8e5eb4e697d663588e1945001ba3ba95dd1480b3c1b846079fadec5972e5ac4462117379052433
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
