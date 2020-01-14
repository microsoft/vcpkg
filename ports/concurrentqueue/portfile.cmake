# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF dea078cf5b6e742cd67a0d725e36f872feca4de4
    SHA512 edd47bcc025ffab7ac62cea168a9672a20cdbe139267426e97553fa1c796f1547d8414915518ee6be34a68d05e8a8171291f958c5eac0434ea8ba953bff85dbe
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
