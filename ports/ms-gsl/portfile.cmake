#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF b43855631afdb9f7ccd4b56ed05330a8e3817af1
    SHA512 fe770217f9ced6fbacfb57ab2f57a33ff2c150cdbadb1e4fc4f0bfe39e98b3940f9f22786a5d30ff7967063caadf7c3cf884a398a7eb6b1d0e219577782fc776
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ms-gsl RENAME copyright)
