# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 0e17140276d215e98764813078f48731125e4784 # 3.0-rc3
    SHA512 fbdf09e3bd0d4e55c27afa314ff231537b57653b7c3d96b51eac2a41de0c302ed093500298f341cb168695bae5d3094fb67e019e93620c11c7d6f8c86d3802e2
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
