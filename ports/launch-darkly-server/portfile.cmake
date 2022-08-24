vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO launchdarkly/c-server-sdk
    REF 0d9db81862e1b17426da9b433a19376dd6458937 # 2.4.3
    SHA512 1bbafd212b0a271909a03319954ee2c92a3dde713fe7f9e0fdd79a5f011f0775701060b66ae9b3a4efad59376241b893d4b3d6679743c41e7657c355c7e3df5c
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DBUILD_TESTING=OFF"
        "-DSKIP_DATABASE_TESTS=OFF"
)

vcpkg_cmake_install()

if(VCPKG_TARGET_IS_WINDOWS)
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/ldserverapi.dll" "${CURRENT_PACKAGES_DIR}/bin/ldserverapi.dll")
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/ldserverapi.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/ldserverapi.dll")
    endif()
endif()

file(REMOVE_RECURSE
	"${CURRENT_PACKAGES_DIR}/debug/include"
	)
    
vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
