# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kunitoki/LuaBridge3
    REF d811afc00bc3d19f548d5aa28ccfe16b09e62ea4 # 3.0-beta4
    SHA512 3ea2ee96a756b4740e3141cc901ea1855536d5e85ab2805df4819a8cd09c8e55263bfd1bf63a2638f85841b3cb373007703d93ce9f63c4f65b4228a03fd40044
    HEAD_REF master
)

# Copy the header files
file(COPY "${SOURCE_PATH}/Source/LuaBridge" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
