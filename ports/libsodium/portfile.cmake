vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jedisct1/libsodium
    REF ${VERSION}
    SHA512 6094d7bf191ea3be85f2ddab76b71f1b9c69c786493db5b84d3c5d5a0237003377ddf6a8687a962ea651fe4a9369cf5ee1676ba0bae82690f5f7ef31a698efa9
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_IS_EMSCRIPTEN)
	set(ADDITIONAL_OPTIONS "-DENABLE_SSP=OFF")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        ${ADDITIONAL_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME unofficial-sodium
)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(REMOVE "${CURRENT_PACKAGES_DIR}/include/Makefile.am")

configure_file(
    "${CMAKE_CURRENT_LIST_DIR}/sodiumConfig.cmake.in"
    "${CURRENT_PACKAGES_DIR}/share/unofficial-sodium/unofficial-sodiumConfig.cmake"
    @ONLY
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
