# header-only library
include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cameron314/concurrentqueue
    REF 9cfda6cc61065d016ae3f51f486ce0fae563ea87 # 1.0.2
    SHA512 1029840d78fb54401d12fbd94fa50b1f5460a61dac606781100a7018c35da3ffd3141f89141d0d7c61d82ca50e02d63e84ae9108d82e5ad43993fe4959fc50d9
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
