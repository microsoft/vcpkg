# header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF 3747268264d0fa113e981658a99ceeae4dad05b7#  v1.0.3
    SHA512 798d61e8e5b87cd1870df20410db18e2fcbc5e4e1d849308663cc0403a0d50d29b72428fc0a39231ae8bcb460c946559bde0f2d22584c335fe849cbcbe607ec2
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

file(GLOB HEADER_FILES ${SOURCE_PATH}/*.h)
file(INSTALL ${HEADER_FILES} DESTINATION ${CURRENT_PACKAGES_DIR}/include/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)