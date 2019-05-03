#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemtrif/utfcpp
    REF v2.3.5
    SHA512 d5e672de952b78a78a8af0c81664f15667b30558fd406a9abc72c14dc444e0869e7c02cb66fa017ec0e760c0fb23c3e923a4b171c2acb3ed7b71612783e789ee
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(INSTALL ${SOURCE_PATH}/source/utf8.h DESTINATION ${CURRENT_PACKAGES_DIR}/share/utfcpp RENAME copyright)

# Copy the utf8-cpp header files
file(COPY ${SOURCE_PATH}/source/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
