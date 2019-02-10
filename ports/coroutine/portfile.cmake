include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO luncliff/coroutine
    REF b65dc006892e11cd4b0ada543927514b6945cfe2
    SHA512 b3e58b024232a2c47755a50db8dce02dbabca57a107e67bc09c0829a4e4ca9c7bd652045159afc1a410ba0989e905116c17b834dd7469f21aa8731a5bb635907
    HEAD_REF vcpkg
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        # package: 'ms-gsl'
        -DGSL_INCLUDE_DIR=${CURRENT_INSTALLED_DIR}/include
        -DTEST_DISABLED=True
)

vcpkg_install_cmake()

file(
    INSTALL     ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/coroutine
    RENAME      copyright
)
# removed duplicates in debug
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
