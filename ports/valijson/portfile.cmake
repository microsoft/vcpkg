#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF v0.6
    SHA512 a493d17159e479be7fe29d45c610c7d4fdd2c2f9ba897923129734fb07257dbb41fddde4c4263dbf0aa5c7101cd1555568a048beba2f60d2b32e625dd9690749
    HEAD_REF master
    PATCHES fix-picojson.patch
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
