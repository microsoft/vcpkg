# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vietjtnguyen/argagg
    REF 0.4.6
    SHA512 7d8cf04a7c679518f01120830637c68719dd67a765457789eb4afedbead7be9efadc6bcdf640999329aaaf8659a5e5d1896f66587068cc668a7c49703aca3070
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
