#header-only library
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/jwt-cpp)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF 1d2b1bac13e54f99df4f890cd674ec149c135762
    SHA512 a45f12104e38a8b05a0ea5b5f91034b65d85dd048664bbda4f2909df32688726d599161e3d6541fd6f36c784d21c24a4d2666f670c3281b9e9130bc8a96fce39
    HEAD_REF master
    PATCHES fix-picojson.patch
            fix-warning.patch)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/jwt-cpp/*)
file(COPY ${HEADER_FILES}
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/jwt-cpp
     REGEX "\.(gitattributes|gitignore|picojson.h)$" EXCLUDE)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/jwt-cpp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jwt-cpp/LICENSE ${CURRENT_PACKAGES_DIR}/share/jwt-cpp/copyright)