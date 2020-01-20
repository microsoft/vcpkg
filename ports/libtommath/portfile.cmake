vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtom/libtommath
    REF v1.2.0
    SHA512 500bce4467d6cdb0b014e6c66d3b994a8d63b51475db6c3cd77c15c8368fbab4e3b5c458fcd5b35838b74c457a33c15b42d2356964f5ef2a0bd31fd544735c9a
    HEAD_REF master
)

# Make sure we start from a clean slate
vcpkg_execute_build_process(
    COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
    WORKING_DIRECTORY ${SOURCE_PATH}
)

#Debug Build
vcpkg_execute_build_process(
    COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc CFLAGS="/MTd"
    WORKING_DIRECTORY ${SOURCE_PATH}/
)

file(INSTALL
    ${SOURCE_PATH}/tommath.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/Debug/lib
)

# Clean up necessary to rebuild without debug symbols
vcpkg_execute_build_process(
    COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc clean
    WORKING_DIRECTORY ${SOURCE_PATH}
)

vcpkg_execute_build_process(
    COMMAND nmake -f ${SOURCE_PATH}/makefile.msvc
    WORKING_DIRECTORY ${SOURCE_PATH}/
)

file(INSTALL
    ${SOURCE_PATH}/tommath.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
    ${SOURCE_PATH}/tommath.h
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)

file(INSTALL
    ${SOURCE_PATH}/LICENSE
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/libtommath/copyright
)