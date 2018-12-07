include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO owt5008137/libcopp
    REF 1.1.0
    SHA512 27b444d158281786154830c6e216e701ba0301af1d7a08873b33e27ce3d2db6ddb4753239878633f4c2aed9f759b46f961408a2eb7b50b5d445c3531c1fa9546
    HEAD_REF v2
)

# Use libcopp's own build process, skipping examples and tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON
)
vcpkg_install_cmake()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/BOOST_LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/copyright)

vcpkg_copy_pdbs()

set(LIBCOPP_FOR_VCPKG_PLATFORM_SUFFIX "")


if(EXISTS "${CURRENT_PACKAGES_DIR}/lib")
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libcopp-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/)
    file(COPY ${CURRENT_PACKAGES_DIR}/lib/cmake/libcopp-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/)
endif()

# if(EXISTS "${CURRENT_PACKAGES_DIR}/lib64")
#     file(COPY ${CURRENT_PACKAGES_DIR}/lib64/cmake/libcopp-config-version.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/)
#     file(COPY ${CURRENT_PACKAGES_DIR}/lib64/cmake/libcopp-config.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/libcopp/)
# endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
