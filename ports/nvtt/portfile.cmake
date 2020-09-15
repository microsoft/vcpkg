include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO castano/nvidia-texture-tools
    REF 2.1.1
    SHA512 3e6fef5977ca29daa7dc97afe11d61de57a8556c9caf30902db8c5c167d9c38f736bcb62eebdaaf7558299b39975bc269d41ab980c813b67dd1fc85064c853c9
    HEAD_REF master
    PATCHES
        001-define-value-for-HAVE_UNISTD_H-in-mac-os.patch
        bc6h.patch
        bc7.patch
        squish.patch
        fix-build-error.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNVTT_SHARED=0
        -DCMAKE_DEBUG_POSTFIX=_d # required by OSG
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(REMOVE ${CURRENT_PACKAGES_DIR}/share/doc/nvtt/LICENSE)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/nvtt)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/nvtt/LICENSE ${CURRENT_PACKAGES_DIR}/share/nvtt/copyright)