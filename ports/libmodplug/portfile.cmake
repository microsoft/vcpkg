set(MODPLUG_HASH 5a39f5913d07ba3e61d8d5afdba00b70165da81d)

include(vcpkg_common_functions)

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    vcpkg_from_github(ARCHIVE
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Konstanty/libmodplug
        REF ${MODPLUG_HASH}
        SHA512 c43bb3190b62c3a4e3636bba121b5593bbf8e6577ca9f2aa04d90b03730ea7fb590e640cdadeb565758b92e81187bc456e693fe37f1f4deace9b9f37556e3ba1
        PATCHES
            "001-automagically-define-modplug-static.patch"
            "002-detect_sinf.patch"
    )
else()
    vcpkg_from_github(ARCHIVE
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Konstanty/libmodplug
        REF ${MODPLUG_HASH}
        SHA512 c43bb3190b62c3a4e3636bba121b5593bbf8e6577ca9f2aa04d90b03730ea7fb590e640cdadeb565758b92e81187bc456e693fe37f1f4deace9b9f37556e3ba1
        PATCHES
            "002-detect_sinf.patch"
    )
endif()

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/modplug.dll ${CURRENT_PACKAGES_DIR}/bin/modplug.dll)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/modplug.dll ${CURRENT_PACKAGES_DIR}/debug/bin/modplug.dll)
    vcpkg_copy_pdbs()
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmodplug)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmodplug/COPYING ${CURRENT_PACKAGES_DIR}/share/libmodplug/copyright)
