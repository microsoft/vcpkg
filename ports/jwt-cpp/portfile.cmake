vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF 08bcf77a687fb06e34138e9e9fa12a4ecbe12332 # v0.7.0
    SHA512 06611120ed0b8fd63051e08e688b9a882f329b8cd10b9d02cbaa4a06d7ef8a924cc4cee64465de954fcde37de105f650cae2b4e4604dc92f6307c930daf346e1
    HEAD_REF master
)

# Copy the header files
file(GLOB HEADER_FILES ${SOURCE_PATH}/include/jwt-cpp/*)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/jwt-cpp)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
