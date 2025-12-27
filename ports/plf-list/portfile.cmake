# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattreecebentley/plf_list
    REF f40dcfec6955fd30b89b8401c666cd08ec7eb030 # 2.7.24
    SHA512 175f87882fd7f8ee72477770d755678f92d1c5616285edfc119a2f37a74312c818d3599295ff989b49ad92f7d1e766f1165c1f219328db54d1d01afbf89fd4b8
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/plf_list.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
