# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF 1d60c7f3004a87eaa9d9cbd647d66361c868558f
    SHA512 b7fdcbee93f032daee65ab95e3a5e87090ff7dfa210fbcf7e7f4e9e236d7deea93a8ffd5b59b7ad4c48fe48414d6d464fad35cf3f85e1aa4fe2cbd8ee368e868
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
