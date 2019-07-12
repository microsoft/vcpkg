include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxbase
    REF v1.21
    SHA512 fa3a959776570704afa8282db66666ebd265d3ffd8cc946abc697dcf2e98a71ab694e290229bb19f760d48f371357463de964ed9e24b0bf272b00b382dfb44c4
    HEAD_REF master
)


if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
	set(BUILD_SHARED_LIBS OFF)
else()
	set(BUILD_SHARED_LIBS ON)
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_TESTS=OFF
	OPTIONS_RELEASE
	OPTIONS_DEBUG
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/ppxbase)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/ppxbase)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/ppxbase)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/ppxbase)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/ppxbase RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

