SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
# Make sure LAPACK can be found

if(VCPKG_TARGET_IS_UWP OR VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm")
    # Install clapack wrappers. 
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/clapack/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share//${PORT})
    file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/clapack/FindLAPACK.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share//${PORT})
endif()
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}")
