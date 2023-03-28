# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF 0e17140276d215e98764813078f48731125e4784 # 3.0-rc3
    SHA512 bfb39b682e0f9acdc1fba0e497073275cf10e70174afb9fcd75424907af85f66b2903025abe5f0712f60dd16e28f288564db38aac1397049765d06fd8f3d4f21
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
