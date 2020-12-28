vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/tuple
    REF 1.0.0
    SHA512 90744b0dad645b5dd56e0223ca7d921d214ed685d84dab838290bb33208b596289e05b9b3eeadda794ce045daf649a6315145bcee5c551de461be65301903fdd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DTAOCPP_JSON_BUILD_TESTS=OFF
        -DTAOCPP_JSON_BUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug
    ${CURRENT_PACKAGES_DIR}/share/doc
)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
