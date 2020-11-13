if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} only supports Windows.")
endif()

# We use `dist` branch instead of `master` branch here,
# as suggested by the library author.
# https://github.com/microsoft/vcpkg/pull/8280
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piscisaureus/wepoll
    REF v1.5.8
    SHA512 e87fbdd0f64a06910fdf29565acff0443b500c409cf7456657829ece3674563581a5c9a298f9ac70f5a0bb78c0a5eb17cfd1a164ab5cbd6fdaacd19d015a3f85
    HEAD_REF dist
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
