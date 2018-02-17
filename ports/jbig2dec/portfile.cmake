include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/jbig2dec
    REF 0.13
    SHA512 11d1209810d6c80a095ec59d6af44010d4664f4ba744c0c14bdad9564359cf31dd0095b072fa63de381f2de57116e523883aa8843cc8d9baa2c3a8b9b1fc3527
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=1
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jbig2dec RENAME copyright)
