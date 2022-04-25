# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO yhirose/cpp-httplib
    REF d73395e1dc652465fa9524266cd26ad57365491f   #v0.10.3
    SHA512 cace318611a1e306b774b4bb08e0312ad06fc10acb829b1df6d5cef9c1d6b018c0c5ebb8e3859fa2bee974dbd51fc5df90a43aa81107c97377d55bb36595b67d
    HEAD_REF master
)

file(COPY "${SOURCE_PATH}/httplib.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
