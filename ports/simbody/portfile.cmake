
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simbody/simbody
    REF 462b2a6dbb8794db2922d72f52b29b488a178ebc
    SHA512 e2b1837e0a04461ebc94e80f5e8aa29f874a1113383db8b24e77b0c9413c4a6bab0299c6a9b2f07147e82ef01a765fed6d6455d5bd059882c646830dd8d1b224
    HEAD_REF master
    PATCHES
        common-name-libs.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC_LIBRARIES)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_DYNAMIC_LIBRARIES)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_DYNAMIC_LIBRARIES=${BUILD_DYNAMIC_LIBRARIES}
        -DBUILD_STATIC_LIBRARIES=${BUILD_STATIC_LIBRARIES}
        -DWINDOWS_USE_EXTERNAL_LIBS=ON
        -DINSTALL_DOCS=OFF
        -DBUILD_VISUALIZER=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DBUILD_TESTS_AND_EXAMPLES_STATIC=OFF
        -DBUILD_TESTS_AND_EXAMPLES_SHARED=OFF
)

vcpkg_cmake_install()

if(WIN32)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/doc")

vcpkg_fixup_pkgconfig()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
