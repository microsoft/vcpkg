include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/secp256k1-0b7024185045a49a1a6a4c5615bf31c94f63d9c4/)

vcpkg_from_github(
	OUT_SOURCE_PATH "secp256k1"
    REPO "bitcoin-core/secp256k1"
	REF "0b7024185045a49a1a6a4c5615bf31c94f63d9c4"
    SHA512 54e0c446ae63105800dfaf23dc934734f196c91f275db0455e58a36926c29ecc51a13d9b1eb2e45bc86199120c3c472ec7b39086787a49ce388a4df462a870bc
)

message("Copying config header to " ${SOURCE_PATH})

file(COPY ${CURRENT_PORT_DIR}/libsecp256k1-config.h DESTINATION ${SOURCE_PATH})

message(STATUS "Building")

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
		-DINSTALL_HEADERS=OFF
	OPTIONS_DEBUG
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/secp256k1 RENAME copyright)
