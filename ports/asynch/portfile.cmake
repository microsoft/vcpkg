vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO naasking/async.h
    REF 080cbb257ab60ad06008c574d7feb94f8478efdd #Commits on Sep 21, 2019 
    SHA512 4fe0229ffd8b3c6438294a419ccb213b4d28a0a04d834406b67120e9bc90d339ec91f3b3eb52d4e27c1f12add41e9347bffbea47868b0d7a1da40f784d113c71
    HEAD_REF master
)

# Copy the single reusable library header
file(COPY ${SOURCE_PATH}/async/async.h DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)