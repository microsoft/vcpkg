if (EXISTS "${CURRENT_INSTALLED_DIR}/share/rbdl-orb/copyright")
    message(FATAL_ERROR "${PORT} conflict with rbdl-orb, please remove rbdl-orb before install ${PORT}.")
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RBDL_STATIC)

vcpkg_from_github(ARCHIVE
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbdl/rbdl
    REF v2.6.0
    SHA512 7b5fd03c0090277f295a28a1ff0542cd8cff76dda4379b3edc61ca3d868bf77d8b4882f81865fdffd0cf756c613fe55238b29a83bc163fc32aa94aa9d5781480
    HEAD_REF master
    PATCHES 001_x64_number_of_sections_exceeded_in_object_file_patch.diff
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DRBDL_BUILD_STATIC=${RBDL_STATIC}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
