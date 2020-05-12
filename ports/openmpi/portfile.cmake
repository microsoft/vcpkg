include(vcpkg_common_functions)

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
  message(FATAL_ERROR "This port is only for openmpi on Unix-like systems")
endif()

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

set(OpenMPI_FULL_VERSION "4.0.1")
set(OpenMPI_SHORT_VERSION "4.0")

vcpkg_download_distfile(ARCHIVE
  URLS "https://download.open-mpi.org/release/open-mpi/v${OpenMPI_SHORT_VERSION}/openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  FILENAME "openmpi-${OpenMPI_FULL_VERSION}.tar.gz"
  SHA512 760716974cb6b25ad820184622e1ee7926bc6fda87db6b574f76792bc1ca99522e52195866c14b7cb2df5a4981efdaf9f71d2c5533cc0e8e45c2c4b3b74cbacc
)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND BUILD_TYPES "release")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND BUILD_TYPES "debug")
endif()

set(SOURCE_PATH_DEBUG   ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/openmpi-${OpenMPI_FULL_VERSION})
set(SOURCE_PATH_RELEASE ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/openmpi-${OpenMPI_FULL_VERSION})
set(OUT_PATH_DEBUG      ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-debug)
set(OUT_PATH_RELEASE    ${SOURCE_PATH_RELEASE}/../../make-build-${TARGET_TRIPLET}-release)
file(REMOVE_RECURSE     ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-debug/)
file(REMOVE_RECURSE     ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-release/)
file(MAKE_DIRECTORY     ${OUT_PATH_DEBUG})
file(MAKE_DIRECTORY     ${OUT_PATH_RELEASE})

foreach(BUILD_TYPE IN LISTS BUILD_TYPES)
    vcpkg_extract_source_archive(${ARCHIVE} ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE})
    #vcpkg_apply_patches(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src-${TARGET_TRIPLET}-${BUILD_TYPE}/openmpi-${OpenMPI_FULL_VERSION} PATCHES patch.file)
endforeach()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
vcpkg_add_to_path(${PERL_PATH})

set(BASH bash)

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "${SOURCE_PATH_DEBUG}/configure --prefix=${OUT_PATH_DEBUG} --enable-debug"
    WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
    LOGNAME "config-${TARGET_TRIPLET}-dbg"
  )
  message(STATUS "Building ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make -j ${VCPKG_CONCURRENCY}"
    NO_PARALLEL_COMMAND ${BASH} --noprofile --norc -c "make"
    WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
    LOGNAME "make-build-${TARGET_TRIPLET}-dbg"
  )
  message(STATUS "Installing ${TARGET_TRIPLET}-dbg")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make install"
    WORKING_DIRECTORY "${SOURCE_PATH_DEBUG}"
    LOGNAME "make-install-${TARGET_TRIPLET}-dbg"
  )
  file(COPY ${OUT_PATH_DEBUG}/lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug)
  message(STATUS "Installing ${TARGET_TRIPLET}-dbg done")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "${SOURCE_PATH_RELEASE}/configure --prefix=${OUT_PATH_RELEASE}"
    WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
    LOGNAME "config-${TARGET_TRIPLET}-rel"
  )
  message(STATUS "Building ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make -j ${VCPKG_CONCURRENCY}"
    NO_PARALLEL_COMMAND ${BASH} --noprofile --norc -c "make"
    WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
    LOGNAME "make-build-${TARGET_TRIPLET}-rel"
  )
  message(STATUS "Installing ${TARGET_TRIPLET}-rel")
  vcpkg_execute_required_process(
    COMMAND ${BASH} --noprofile --norc -c "make install"
    WORKING_DIRECTORY "${SOURCE_PATH_RELEASE}"
    LOGNAME "make-install-${TARGET_TRIPLET}-rel"
  )
  file(COPY ${OUT_PATH_RELEASE}/lib DESTINATION ${CURRENT_PACKAGES_DIR})
  file(COPY ${OUT_PATH_RELEASE}/include DESTINATION ${CURRENT_PACKAGES_DIR})
  file(COPY ${OUT_PATH_RELEASE}/share DESTINATION ${CURRENT_PACKAGES_DIR})
  file(COPY ${OUT_PATH_RELEASE}/bin DESTINATION ${CURRENT_PACKAGES_DIR})
  message(STATUS "Installing ${TARGET_TRIPLET}-rel done")
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
  file(INSTALL ${SOURCE_PATH_DEBUG}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmpi RENAME copyright)
else()
  file(INSTALL ${SOURCE_PATH_RELEASE}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/openmpi RENAME copyright)
endif()
