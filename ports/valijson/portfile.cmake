#header-only library
include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/valijson)

vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF dd084d747448bb56ddfeab5946b4f2f4617b99c4
    SHA512 ee241eefc816360608f86792a4c25abadea79cbffc94d7e31a2dbd0a483ed4d7a303b6d2410b99ab7694e58a3d299f0df0baa52fa16f89e9233d90b190a4d799
    HEAD_REF master
    PATCHES fix-nlohmann-json.patch
            fix-picojson.patch
            fix-optional.patch
)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/valijson/*)
file(COPY ${HEADER_FILES}
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/valijson
     REGEX "\.(gitattributes|gitignore)$" EXCLUDE)

file(COPY ${SOURCE_PATH}/include/compat/optional.hpp
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/valijson/compat)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE
     DESTINATION ${CURRENT_PACKAGES_DIR}/share/valijson)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/valijson/LICENSE ${CURRENT_PACKAGES_DIR}/share/valijson/copyright)