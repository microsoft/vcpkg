include(vcpkg_common_functions)

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(FATAL_ERROR "${PORT} only supports Windows.")
endif()

# We use `dist` branch instead of `master` branch here,
# as suggested by the library author.
# https://github.com/microsoft/vcpkg/pull/8280
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO piscisaureus/wepoll
    REF v1.5.5
    SHA512 af4507e864b0345a5842c71f4a036488ed51e53a310c7b76e7caef89f29c3a53bf7ccfea8ac4aaea386de1d1e589425004fc16bc31b2900a0ba730f0a54cb357
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
