vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xeus
    REF 424b7cd177886906a59eee535b7de59088461910 # 0.24.1
    SHA512 877ca45bf649b567a9921d3e8f0adb0299dbe956978bd6e217d0c06617cf3466d08d90d607fd33e129089472e1a96ecec78b1fc21346bc13ba268168a5a6b068
    HEAD_REF master
    PATCHES
		Fix-Compile-nlohmann-json.patch
		Fix-static-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDISABLE_ARCH_NATIVE=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(COPY
    ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/xeus/xeus.hpp
        "#ifdef XEUS_STATIC_LIB"
        "#if 1 // #ifdef XEUS_STATIC_LIB"
    )
	file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
