set(ARCHIVE_NAME "sundials-5.5.0")

vcpkg_download_distfile(ARCHIVE
    URLS "https://computation.llnl.gov/projects/sundials/download/${ARCHIVE_NAME}.tar.gz"
    FILENAME "${ARCHIVE_NAME}.tar.gz"
    SHA512 e8cba7341f6b8d647151fe5543e62a13adda363d4c96bdaba7a70925b2c58ec4f4f089a0d6c9c5a57c50fb32fa1285bd09b450697056bc3da24cf882c6c7c427
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SUN_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SUN_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DEXAMPLES_ENABLE=OFF
        -DBUILD_STATIC_LIBS=${SUN_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${SUN_BUILD_SHARED}
)

vcpkg_install_cmake(DISABLE_PARALLEL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(GLOB REMOVE_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

file(GLOB DEBUG_DLLS
    "${CURRENT_PACKAGES_DIR}/debug/lib/*.dll"
)

file(GLOB DLLS
    "${CURRENT_PACKAGES_DIR}/lib/*.dll"
)

if(DLLS)
    file(INSTALL ${DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
endif()

if(DEBUG_DLLS)
    file(INSTALL ${DEBUG_DLLS} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")

if(REMOVE_DLLS)
    file(REMOVE ${REMOVE_DLLS})
endif()

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
