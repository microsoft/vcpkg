
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simbody/simbody
    REF 040562785acd4b6d9d26ea6762d5c80075e0c474
    SHA512 b803ed45fbaa60c5af601ac2d0be2a109eae19428d72ab06952403e12116ee08592014d85accad8e6a64aed6bb0afbd6f9dff6588c4b22da65fd1bac067f8662
    HEAD_REF master
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

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
