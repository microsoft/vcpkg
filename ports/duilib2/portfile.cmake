include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/duilib2
    REF v1.35
    SHA512 a2bd6e8e9f3bc1e02394034ce7704ec3b2d4a88d0e2181e656c7610bb743545ca57c2f46f4e86e0fb119c6ee06830d8bbe13a0bb6d67422c1756592a8b466318
    HEAD_REF master
)


if("${VCPKG_LIBRARY_LINKAGE}" STREQUAL "static")
	set(BUILD_SHARED_LIBS OFF)
else()
	set(BUILD_SHARED_LIBS ON)
endif()

set(UILIB_WITH_CEF OFF)
if("cef" IN_LIST FEATURES)
    set(UILIB_WITH_CEF ON)
	message(STATUS "UILIB_WITH_CEF=ON")
endif()


vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
        -DBUILD_TESTS=OFF
		-DUILIB_WITH_CEF=${UILIB_WITH_CEF}
	OPTIONS_RELEASE
	OPTIONS_DEBUG
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/duilib2)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/duilib2)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/duilib2)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/duilib2)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/duilib2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)


vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

