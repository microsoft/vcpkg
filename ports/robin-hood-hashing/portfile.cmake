# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinus/robin-hood-hashing
    REF 3.4.0
    SHA512 7985d64063af7d28b9404639df48645d2d72b0bc752fde23c7e3bf431adbd8eb4ffbc439e5a8513a39eb54481ce875fb044fafc86c36046995e3193284a594dd
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src/include/robin_hood.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
