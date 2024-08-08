vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kenba/via-httplib
    REF b1baffa347b5a5a0b02e687ccc6273f26e1f7515 # v1.9.0
    SHA512 a756c8869f5d17df3bdf8a83995f211b7a23cef6aacf916c9f4fbff365b8a6f4d2499154fc6de2db97de65b2dccbcc4a953aed37da68d8478cf1a9e38ac03d9a
    HEAD_REF master    
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}" )

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ViaHttpLib)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib" 
                    "${CURRENT_PACKAGES_DIR}/lib"
                    "${CURRENT_PACKAGES_DIR}/debug"
                    )

file(INSTALL "${SOURCE_PATH}/LICENSE_1_0.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/via-httplib" RENAME copyright)
