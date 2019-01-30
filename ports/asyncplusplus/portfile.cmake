include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Amanieu/asyncplusplus
    REF v1.0
    SHA512 bb1fc032d2d8de49b4505e0629d48e5cfa99edfcafbf17848f160ceb320bcd993f1549095248d1a0ef8fc1ec07ecbaad6b634a770ddc1974092d373a508a5fe3
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(RENAME ${CURRENT_PACKAGES_DIR}/cmake/Async++.cmake ${CURRENT_PACKAGES_DIR}/cmake/Async++Targets.cmake)

# Fix targets import paths
vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/async++)
set(TARGETS_CMAKE ${CURRENT_PACKAGES_DIR}/share/async++/Async++Targets.cmake)
file(READ ${TARGETS_CMAKE} _contents)
string(REGEX REPLACE
    "get_filename_component\\(_IMPORT_PREFIX \"\\\${CMAKE_CURRENT_LIST_FILE}\" PATH\\)(\nget_filename_component\\(_IMPORT_PREFIX \"\\\${_IMPORT_PREFIX}\" PATH\\))*"
    "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
    _contents "${_contents}")
file(WRITE ${TARGETS_CMAKE} "${_contents}")
file(RENAME ${TARGETS_CMAKE} ${CURRENT_PACKAGES_DIR}/share/async++/Async++.cmake)

# Update Async++Config.cmake
file(READ ${CURRENT_PACKAGES_DIR}/share/async++/Async++Config.cmake _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/async++/Async++Config.cmake "include(CMakeFindDependencyMacro)\n${_contents}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/asyncplusplus)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/asyncplusplus/LICENSE ${CURRENT_PACKAGES_DIR}/share/asyncplusplus/copyright)

vcpkg_test_cmake(PACKAGE_NAME Async++)
