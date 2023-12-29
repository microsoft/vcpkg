vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Thalhammer/jwt-cpp
    REF 08bcf77a687fb06e34138e9e9fa12a4ecbe12332 # v0.7.0
    SHA512 06611120ed0b8fd63051e08e688b9a882f329b8cd10b9d02cbaa4a06d7ef8a924cc4cee64465de954fcde37de105f650cae2b4e4604dc92f6307c930daf346e1
    HEAD_REF master
)

# Copy the header files
vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DJWT_BUILD_EXAMPLES=OFF
    )
vcpkg_cmake_config_fixup()
vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
