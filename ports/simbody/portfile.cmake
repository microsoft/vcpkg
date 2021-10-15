vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO simbody/simbody
    REF 23c39e9356e9f052bcc9e498a5dd357554bbaf89
    SHA512 e11de8193ca1e0f7a1c54b137e2d2c3cd3a9bb705df352d8f069023975c6037b1a3be7ed41b288939fa308530b775744f7d729429d9734b0968067f3ef1f49ef
    HEAD_REF master
)
file(REMOVE_RECURSE "${SOURCE_PATH}/Platform/Windows")

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
)

vcpkg_cmake_install()

if(WIN32)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH ${CMAKE_INSTALL_LIBDIR}/cmake/${PORT})
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
