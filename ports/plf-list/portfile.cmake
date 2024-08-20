# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_list
    REF 42fcfca9890598d1c1fda45eb9dbe2b2b2d4dd2b
    SHA512 879157aac16dc1b76db942a8ddf25dc33ede10e769496b7f300a070913c6c6946cb40853dd3071ecf3d9c870e1dee5d420d42fbb388e83361235659171f6bd44
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_list.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
