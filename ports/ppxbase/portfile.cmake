include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxbase
    REF v1.38
    SHA512 84d1b72f05ba22c0b71fcf9d58d118071edff90741687708d39c3c4a6381730b397cb759f799f75a694ee3a694a1b06d25c6552574888df77dab86299d256e18
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

