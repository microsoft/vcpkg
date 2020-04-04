include(vcpkg_common_functions)

if(${VCPKG_TARGET_ARCHITECTURE} MATCHES x86)
    message(WARNING "This library may not work correctly in x86 arch. Please consider using x64 instead")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    # will be changed to 1.5.0
    REF             674e6626a41d142d90a4a0f8b5282ac28957990d
    SHA512          3289b6a3cc0e6379bf1a8eb1c9a281fd275c5fde13c0d0de22a21aa61cf94c13e4997e76534619e13fa5cee864b5cb8e23e1b8e80bf3eda97d10b7a16e3fb0e6
    HEAD_REF        master
)

# package: 'ms-gsl'
set(GSL_INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include
    CACHE PATH "path to include C++ core guideline support library" FORCE)
message(STATUS "using ms-gsl(vcpkg): ${GSL_INCLUDE_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_INCLUDE_DIR=${GSL_INCLUDE_DIR}
        -DBUILD_TESTING=False
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
