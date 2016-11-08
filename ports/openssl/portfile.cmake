include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openssl-1.0.2j)
vcpkg_find_acquire_program(PERL)
find_program(NMAKE nmake)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_EXE_PATH};$ENV{PATH}")

vcpkg_download_distfile(OPENSSL_SOURCE_ARCHIVE
    URLS "https://www.openssl.org/source/openssl-1.0.2j.tar.gz"
    FILENAME "openssl-1.0.2j.tar.gz"
    SHA512 7d6ccae4aa3ccec3a5d128da29c68401cdb1210cba6d212d55235fc3bc63d7085e2f119e2bbee7ddff6b7b5eef07c6196156791724cd2caf313a4c2fef724edd
)

file(COPY
${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
${CMAKE_CURRENT_LIST_DIR}/PerlScriptSpaceInPathFixes.patch
${CMAKE_CURRENT_LIST_DIR}/ConfigureIncludeQuotesFix.patch
${CMAKE_CURRENT_LIST_DIR}/STRINGIFYPatch.patch
DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    GENERATOR "NMake Makefiles"
    OPTIONS
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
        -DCURRENT_PACKAGES_DIR=${CURRENT_PACKAGES_DIR}
        -DCURRENT_BUILDTREES_DIR=${CURRENT_BUILDTREES_DIR}
        -DOPENSSL_SOURCE_ARCHIVE=${OPENSSL_SOURCE_ARCHIVE}
        -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
        -DTRIPLET_SYSTEM_ARCH=${TRIPLET_SYSTEM_ARCH}
        -DVERSION=1.0.2j
        -DTARGET_TRIPLET=${TARGET_TRIPLET}
)

message(STATUS "Build ${TARGET_TRIPLET}-rel")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build .
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
    LOGNAME build-${TARGET_TRIPLET}-rel
)
message(STATUS "Build ${TARGET_TRIPLET}-rel done")

message(STATUS "Build ${TARGET_TRIPLET}-dbg")
vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} --build .
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
    LOGNAME build-${TARGET_TRIPLET}-dbg
)
message(STATUS "Build ${TARGET_TRIPLET}-dbg done")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/debug/bin/openssl.exe
    ${CURRENT_PACKAGES_DIR}/bin/openssl.exe
    ${CURRENT_PACKAGES_DIR}/debug/openssl.cnf
    ${CURRENT_PACKAGES_DIR}/openssl.cnf
)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl RENAME copyright)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    # They should be empty, only the exes deleted above were in these directories
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin/)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)
endif()

vcpkg_copy_pdbs()