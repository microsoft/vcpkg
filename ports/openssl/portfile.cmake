include(vcpkg_common_functions)
vcpkg_find_acquire_program(PERL)
find_program(NMAKE nmake)

get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "${PERL_EXE_PATH};$ENV{PATH}")

vcpkg_download_distfile(OPENSSL_SOURCE_ARCHIVE
    URL "https://www.openssl.org/source/openssl-1.0.2h.tar.gz"
    FILENAME "openssl-1.0.2h.tar.gz"
    MD5 9392e65072ce4b614c1392eefc1f23d0
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${CURRENT_BUILDTREES_DIR}/src/openssl-1.0.2h)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/openssl-1.0.2h
    GENERATOR "NMake Makefiles"
    OPTIONS
        -DCURRENT_INSTALLED_DIR=${CURRENT_INSTALLED_DIR}
        -DCURRENT_PACKAGES_DIR=${CURRENT_PACKAGES_DIR}
        -DCURRENT_BUILDTREES_DIR=${CURRENT_BUILDTREES_DIR}
        -DOPENSSL_SOURCE_ARCHIVE=${OPENSSL_SOURCE_ARCHIVE}
        -DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}
        -DTRIPLET_SYSTEM_ARCH=${TRIPLET_SYSTEM_ARCH}
        -DVERSION=1.0.2h
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
if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/engines)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/engines ${CURRENT_PACKAGES_DIR}/bin/engines)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/engines)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/engines ${CURRENT_PACKAGES_DIR}/debug/bin/engines)
endif()
file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openssl RENAME copyright)
vcpkg_copy_pdbs()
