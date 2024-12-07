function(remove_empty_directories_recursive dir)
    file(GLOB before_subdirs "${dir}/*")
    foreach (subdir ${before_subdirs})
        if (IS_DIRECTORY ${subdir})
            remove_empty_directories_recursive(${subdir})
        endif ()
    endforeach ()
    file(GLOB after_subdirs "${dir}/*")
    if ("${after_subdirs}" STREQUAL "")
        file(REMOVE_RECURSE "${dir}")
    endif ()
endfunction()

set(SOURCE_PATH ${CURRENT_BUILDTRESS_DIR}/sese)

vcpkg_download_distfile(PATCH_FIX_ENV_STATEMENT  
    URLS https://github.com/libsese/sese/commit/59fa66d24996eceddc2c406b043687cd13a741dd.patch?full_index=1  
    SHA512 94661bf2306c40dd3d62409babf26787087e7bc3abade532e9b656080de2f237fd640465272228055da250670d286ede10bd8776cc0d67429d6e0846cfd06d5e  
    FILENAME libsese-sese-2.3.0-59fa66d24996eceddc2c406b043687cd13a741dd.patch  
)

vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO libsese/sese
        REF "73e1e90be5907e97c27191a72eb22143caabfca1"
        SHA512 6724bbbce25c718d8ebae4f36deb96fa696d1ee37b9199897224e4789bfeb6fee4288aaf247ec88243a9e63de8906ca748cc1ce7313a0ed4e3104293683337ae
        PATCHES
            ${PATCH_FIX_ENV_STATEMENT}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
        tests            SESE_BUILD_TEST
        mysql            SESE_DB_USE_MARIADB
        sqlite3          SESE_DB_USE_SQLITE
        psql             SESE_DB_USE_POSTGRES
        async-logger     SESE_USE_ASYNC_LOGGER
        archive          SESE_USE_ARCHIVE
        replace-execinfo SESE_REPLACE_EXECINFO
)

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/sese")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
if(VCPKG_BUILD_TYPE)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

remove_empty_directories_recursive("${CURRENT_PACKAGES_DIR}/include/sese")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/NOTICE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
