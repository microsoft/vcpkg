include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/duilib2
    REF 539d423fe0b7afc6fefe31325c2d2879de84e704
    SHA512 c9ce63a18bb486329b3f9273e7f05ba5208af566cf5c67eb4eee09e824dba71e467e39f9274474b3e83ffbec6d89c6b8ea2bfbb862a8a18de87d418b21d26e34
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

