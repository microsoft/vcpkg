include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO GNOME/libxml2
    REF v2.9.9
    SHA512 bfcc08bd033f538a968205f0f9e2da4c3438ec2f35f017289783903365e13ed93d83f2f63c7497344a362b7418170ee586a5ecb45493e30feaa0f62b22a57b54
    HEAD_REF master
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DPORT_DIR=${CMAKE_CURRENT_LIST_DIR}
    OPTIONS_DEBUG -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()

# Handle copyright
configure_file(${SOURCE_PATH}/Copyright ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libxml2)
endif()
