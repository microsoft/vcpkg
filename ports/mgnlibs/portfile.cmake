#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattiasgustavsson/libs
    REF 9a6e7205caecbe336e41aebdc9c79a5c47daa5ec
    SHA512 87493f883f0752a334bbcec69228e325d9e1f36a99d313be9243f4e6e14876bcd5a976682d3fd7e3e285e426ac69587d35ba3378b2124450b9a8ed6127f110a5
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/mgnlibs/README.md)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mgnlibs/README.md ${CURRENT_PACKAGES_DIR}/share/mgnlibs/copyright)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/mgnlibs)
