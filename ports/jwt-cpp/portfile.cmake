vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF 34bb0644ea613cfcbc09c148db9de8aa6c5612b5 # v0.4.0
    SHA512 773007fc7a73a831e292451d7a38feb9434f7c11c653d43b9f3679c564f64805a1cbd1baab6b13107c42cc06549ad7cd08aebd6658d8ee0022f5b8d601fa94cc
    HEAD_REF master
    PATCHES
        fix-warning.patch
)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/jwt-cpp/*)
file(COPY ${HEADER_FILES}
     DESTINATION ${CURRENT_PACKAGES_DIR}/include/jwt-cpp
     REGEX "\.(gitattributes|gitignore|picojson.h)$" EXCLUDE)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
