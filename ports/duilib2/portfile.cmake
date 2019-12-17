include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/duilib2
    REF 43cbb1b6217a3f0eaf86cf896815a801674b5570
    SHA512 3f344cbcb3e8e7d3246ddb2edeb4394b4979de4eb7f9edae4f5aff6743332c13f6f972d895cf717f35449f7cb56ad39ff078ac7969748a4542cab0749a43a112
    HEAD_REF master
)


if("VCPKG_LIBRARY_LINKAGE" STREQUAL "static")
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

