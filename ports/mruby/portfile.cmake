set(VERSION 3.2.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mruby/mruby
    REF ${VERSION}
    SHA512 bb46fa0eda6507cabe775e3f9cceec6da64d5a96c20e704e7ada94f5b4906989553c363cfd85789c4adcb030a6cfd36b8a99d8247f32687c913bbe06edb9bbca
    HEAD_REF master
)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
vcpkg_execute_in_download_mode(
    COMMAND rake
    WORKING_DIRECTORY "${SOURCE_PATH}"
)

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)