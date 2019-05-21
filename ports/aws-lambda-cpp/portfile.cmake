include(vcpkg_common_functions)

if(NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(FATAL_ERROR "aws-lambda-cpp currently only supports Linux and Mac platforms")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-lambda-cpp
    REF v0.1.0
    SHA512 78b1ad1dcd88176a954c03b38cbb962c77488da6c75acb37a8b64cde147c030b02c6e51f0a974edb042e59c3c969d110d181ad097ef76f43255500b272a94454
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/aws-lambda-cpp RENAME copyright)

