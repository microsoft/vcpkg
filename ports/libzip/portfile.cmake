include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nih-at/libzip
    REF rel-1-5-2
    SHA512 5ba765c5d4ab47dff24bfa5e73b798046126fcc88b29d5d9ce9d77d035499ae91d90cc526f1f73bbefa07b7b68ff6cf77e912e5793859f801caaf2061cb20aee
    HEAD_REF master
	PATCHES avoid_computation_on_void_pointer.patch
)

# AES encryption
set(USE_OPENSSL OFF)
if("openssl" IN_LIST FEATURES)
    set(USE_OPENSSL ON)
endif()

set(USE_BZIP2 OFF)
if("bzip2" IN_LIST FEATURES)
    set(USE_BZIP2 ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_DOC=OFF
        -DBUILD_EXAMPLES=OFF
        -DBUILD_REGRESS=OFF
        -DBUILD_TOOLS=OFF
        # see https://github.com/nih-at/libzip/blob/rel-1-5-2/INSTALL.md
        -DENABLE_OPENSSL=${USE_OPENSSL}
        -DENABLE_BZIP2=${USE_BZIP2}
)

vcpkg_install_cmake()

# Remove include directories from lib
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/libzip ${CURRENT_PACKAGES_DIR}/debug/lib/libzip)

# Remove debug include
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Copy copright information
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libzip RENAME copyright)

vcpkg_copy_pdbs()
