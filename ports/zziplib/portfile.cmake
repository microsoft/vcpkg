vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gdraheim/zziplib
    REF 24a6c6de1956189bffcd8dffd2ef3197c6f3df29 # v0.13.71
    SHA512 246ee1d93f3f8a6889e9ab362e04e6814813844f2cdea0a782910bf07ca55ecd6d8b1c456b4180935464cebf291e7849af27ac0ed5cc080de5fb158f9f3aeffb
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
