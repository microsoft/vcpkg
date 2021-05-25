vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF v0.9.0-pre13
    SHA512 cce4e4f3316c9cc65f2026d0734e1f962079febfcf51c59a673899dace60b71604440c647652769db97e9b253d1eb9667921da2c76ff8c2d453e768eb49585fb
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SAIL_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAIL_STATIC=${SAIL_STATIC}
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_BUILD_EXAMPLES=OFF
        -DSAIL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sail)

# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Handle usage
if (UNIX AND NOT APPLE)
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage.unix DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage.unix ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage)
else()
    file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
endif()

# Move C++ configs
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT}c++)
file(GLOB SAIL_CPP_CONFIGS "${CURRENT_PACKAGES_DIR}/share/${PORT}/SailC++*")
foreach(SAIL_CPP_CONFIG IN LISTS SAIL_CPP_CONFIGS)
    get_filename_component(SAIL_CPP_CONFIG_NAME "${SAIL_CPP_CONFIG}" NAME)
    file(RENAME ${SAIL_CPP_CONFIG} ${CURRENT_PACKAGES_DIR}/share/${PORT}c++/${SAIL_CPP_CONFIG_NAME})
endforeach()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/${PORT}manip)
file(GLOB SAIL_MANIP_CONFIGS "${CURRENT_PACKAGES_DIR}/share/${PORT}/SailManip*")
foreach(SAIL_MANIP_CONFIG IN LISTS SAIL_MANIP_CONFIGS)
    get_filename_component(SAIL_MANIP_CONFIG_NAME "${SAIL_MANIP_CONFIG}" NAME)
    file(RENAME ${SAIL_MANIP_CONFIG} ${CURRENT_PACKAGES_DIR}/share/${PORT}manip/${SAIL_MANIP_CONFIG_NAME})
endforeach()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
