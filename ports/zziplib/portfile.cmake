include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF v0.13.69
    SHA512 ade026289737f43ca92a8746818d87dd7618d473dbce159546ce9071c9e4cbe164a6b1c9efff16efb7aa0327b2ec6b34f3256c6bda19cd6e325703fffc810ef0
)

# Run configure
if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux" OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    message(STATUS "Configuring zziplib")
    vcpkg_execute_required_process(
        COMMAND "./configure" --prefix=${CURRENT_INSTALLED_DIR} --with-zlib
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME "autotools-config-${TARGET_TRIPLET}"
    )
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS -DZLIB_INCLUDE_DIRS=${CURRENT_INSTALLED_DIR}/include
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/zziplib)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/zziplib/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/zziplib/copyright)
