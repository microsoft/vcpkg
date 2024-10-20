if ((VCPKG_LIBRARY_LINKAGE STREQUAL dynamic) AND (CMAKE_HOST_SYSTEM_NAME STREQUAL Windows))
    message(STATUS "${PORT} doesn't support building as dynamic library on Windows, overriding to static")
    set(VCPKG_LIBRARY_LINKAGE static)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "osqp/osqp"
    REF v0.6.2     
    SHA512 1e3e1e06891ba862d982f9f37503580268709bf1ea5008daab95393501c85aa69c79d321c45bc87dc53000274dd120c148b90c1797156e340fe361929ff2e324
    PATCHES osqp.patch
)

vcpkg_download_distfile(
    QDLDL
    URLS "https://github.com/osqp/qdldl/archive/refs/tags/v0.1.5.tar.gz"
    FILENAME "qdldl-0.1.5.tar.gz"
    SHA512 3a224767708484d6728e4b0801210c5e7d4e906564c0855c7987876316cde7349c2717a169b4a6680495b0c71415be383e3e5c6826873fb92d7e93258a7a03a8
)

vcpkg_extract_source_archive(
    QDLDL_SOURCE_PATH
    ARCHIVE "${QDLDL}"
    PATCHES qdldl.patch
)

vcpkg_execute_required_process(
    COMMAND ${CMAKE_COMMAND} -E copy_directory "${QDLDL_SOURCE_PATH}" "${SOURCE_PATH}/lin_sys/direct/qdldl/qdldl_sources/" 
    WORKING_DIRECTORY "${SOURCE_PATH}"
    LOGNAME copy                
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/osqp"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)
