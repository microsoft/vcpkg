vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO master-keying/minisat
    REF 60f47c0b59a5116639a73ceb9b50eb818536af0b
    SHA512 267b7dd44bd1390826228c45ce0e71976a78940d2086470a26b59a6c692ad5e0e911c255eda0c187c33f8138b34deab59aa53191a0e1a46df38c5b73680d74d6
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/MiniSat TARGET_PATH share/minisat)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/minisat-master-keying RENAME copyright)
