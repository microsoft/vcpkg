vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tgockel/zookeeper-cpp
    REF v0.2.3
    SHA512 086f31d4ca53f5a585fd8640caf9f2f21c90cf46d9cfe6c0e8e5b8c620e73265bb8aebec62ea4328f3f098a9b3000280582569966c0d3401627ab8c3edc31ca8
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  "${SOURCE_PATH}")
file(GLOB_RECURSE test_files LIST_DIRECTORIES false "${SOURCE_PATH}/src/zk/*_tests.cpp")
if (NOT "${test_files}" STREQUAL "")
	file(REMOVE ${test_files})
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()
