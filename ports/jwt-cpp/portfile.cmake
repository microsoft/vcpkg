vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF 4a537e969891dde542ad8b1a4a214955a83be29f # v0.6.0
    SHA512 eeeb6adb7f94b699a020b5622b9dbb6c677d92779b57bfb2298b331a5cf69d9112d0b123f0c2ca235ecd96df6d32fcf44e85e144fa414aeff8fd67e3b87576d2
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/jwt-cpp/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/jwt-cpp)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
