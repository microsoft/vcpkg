vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF b45bc9994d8087c5ba7aa1f1588302f04ae84c83 # v0.5.0
    SHA512 fcc2fef58d6c9afbdb6f587dc3e6c2bb1e6e585314dd016c43c99ba1dbd8996b2cdd9e8d81c94195489b0ae48d61dffbfc9dcc5b68cbc5b9ea0d84fd74cd4ff1
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/jwt-cpp/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/jwt-cpp)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
