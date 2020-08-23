# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF 79cec4c3bf1ca23ea4a03adfcd3c2c3659684dd2 # v1.0.1
    SHA512 04f4d378cfc3d90772144e89c0ec6b310354befb3f2068bf8b16f5f672604436149fef04035435f2067f606241cb726702941cf17b0305aa5cf32bd51b5c3bbd
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-concurrentqueue TARGET_PATH share/unofficial-concurrentqueue)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

configure_file(
    ${CMAKE_CURRENT_LIST_DIR}/unofficial-concurrentqueue-config.in.cmake
    ${CURRENT_PACKAGES_DIR}/share/unofficial-concurrentqueue/unofficial-concurrentqueue-config.cmake
    @ONLY
)

file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/concurrentqueue RENAME copyright)

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(COPY ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/concurrentqueue)
