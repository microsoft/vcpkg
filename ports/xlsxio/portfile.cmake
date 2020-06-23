
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO brechtsanders/xlsxio
    REF 489279e51404eac10458d48fb4c68dfc7e4950fe
    SHA512 afc75b272ade916d1b6f0aa4fd5b6dad263a11fe0aac0ca939fed1f0c5c12d0d0d831f25e19449e33c6a6151410cbb7dd9f327896011dcfd6165375de4fd50ea
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TOOLS=OFF
        -DBUILD_STATIC=ON
        -DBUILD_SHARED=OFF
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
