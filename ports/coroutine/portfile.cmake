
# for Linux, the port requires libc++ and Clang or GCC 10+
vcpkg_fail_port_install(ON_TARGET "uwp" "linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            luncliff/coroutine
    REF             1.5.0
    SHA512          61b91fdc641b6905b884e99c5bf193ec2cf6962144ab3baafdb9432115757d96f3797f116b30356f0d21417b23082bc908f75042721caeab3329c4910b654594
    HEAD_REF        master
)

# package: 'ms-gsl'
set(GSL_INCLUDE_DIR ${CURRENT_INSTALLED_DIR}/include
    CACHE PATH "path to include C++ core guideline support library" FORCE)
message(STATUS "Using ms-gsl(vcpkg): ${GSL_INCLUDE_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DGSL_INCLUDE_DIR=${GSL_INCLUDE_DIR}
        -DBUILD_TESTING=False
)
vcpkg_install_cmake()

file(INSTALL        ${SOURCE_PATH}/LICENSE
     DESTINATION    ${CURRENT_PACKAGES_DIR}/share/${PORT}
     RENAME         copyright
)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
