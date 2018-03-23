#header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO chriskohlhoff/asio
    REF asio-1-12-0
    SHA512 a0e341fd6a848784e1533df84d1e6b361c8468f59d4fbde68c1500c1f8a2124ad78db0169098dbbc594ce26717eb9760f37af13cb288a549e2bda563eecf2be3
    HEAD_REF master
)

# Handle copyright
file(COPY ${SOURCE_PATH}/asio/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

# Copy the asio header files
file(INSTALL ${SOURCE_PATH}/asio/include DESTINATION ${CURRENT_PACKAGES_DIR} FILES_MATCHING PATTERN "*.hpp" PATTERN "*.ipp")
