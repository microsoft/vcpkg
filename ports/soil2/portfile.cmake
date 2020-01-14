include(vcpkg_common_functions)

# Download the release-1.11 from bitbucket
vcpkg_from_bitbucket(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SpartanJ/soil2
    REF release-1.11
    SHA512 203c2306fd72e24b9e990cb054f3b1b0391eaf26ed645842fb381971673dab8ea20c2739c8dff1fc11c83d6f66add0ad77ae79d8ff68930e3e1cb003e34f2414
    HEAD_REF master
)

# Copy the CMakeLists and LICENSE
file(
    COPY 
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    ${CMAKE_CURRENT_LIST_DIR}/LICENSE
    ${CMAKE_CURRENT_LIST_DIR}/soil2Config.cmake.in
    ${CMAKE_CURRENT_LIST_DIR}/soil2ConfigVersion.cmake.in
    DESTINATION ${SOURCE_PATH}
)

# Configure the cmake file (we imported)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

# Run the install
vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/soil2 RENAME copyright)
