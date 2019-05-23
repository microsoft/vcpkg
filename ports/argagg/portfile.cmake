# header-only library

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vietjtnguyen/argagg
    REF e678cebf90d8f132f5e54f19c6b95b75e655226c
    SHA512 10085caaf9bfb507ae7117b61bfe6174dc2af91c347393c3cbb994fe5b824d4b439e1e0d2e2580dc34568d8046529acc211f76863be047d05d3845e9ff19ccbf
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DARGAGG_BUILD_EXAMPLES=OFF
        -DARGAGG_BUILD_TESTS=OFF
        -DARGAGG_BUILD_DOCS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
