vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO winsoft666/ppxbase
    REF bff0968c6fcd71f68cf9a9aae5359b6fb98ab2d2
    SHA512 a6259d6633e9173981d725628ac06b7e5faea9bbd04c6afbf6af3e2da0a461ec72ee45e0c1755781a48bc2c4bbd04892f042078a46816c37374450ee8827f453
    HEAD_REF master
)


if("VCPKG_LIBRARY_LINKAGE" STREQUAL "static")
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

