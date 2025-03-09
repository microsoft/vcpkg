set(VCPKG_POLICY_ALLOW_DEBUG_INCLUDE enabled)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

if(NOT VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_LINUX)
    message(FATAL_ERROR "minha-biblioteca only supports Windows and Linux")
endif()

vcpkg_from_github(
   OUT_SOURCE_PATH SOURCE_PATH
   REPO Darkx32/AudioEngine
   REF "${VERSION}"
   SHA512 56025f415f6f45e8085f476e98335e922c97e47844bc12f9fc3c14cf108a1934cbb02a67e9a765c1ceb27d3f26b665e47ed4a03539dd50946c20cca980d706d0
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
       -DAUDIOENGINE_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
