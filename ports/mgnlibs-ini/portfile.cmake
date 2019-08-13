#header-only library
include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mattiasgustavsson/libs
    REF 022370a79cf2d5f87fb43b420834a069adb5fede
    SHA512 f3ebd2dd8eb16615fd6917a828050e93dc3ccb8ce4a14ae33bbaa2d8911341d60dae642a5f4216a3fbf770865424f98944d35efc1885bcd0ce60e60e200d0de1
    HEAD_REF master
)

# Put the licence file where vcpkg expects it
file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/mgnlibs-ini)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/mgnlibs-ini/README.md ${CURRENT_PACKAGES_DIR}/share/mgnlibs-ini/copyright)

# Copy the header file
file(COPY ${SOURCE_PATH}/ini.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

