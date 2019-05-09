include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libfann/fann
    REF 2.2.0
    SHA512 b307539a39d93078a489710ac77aa8c6e324f3cf5ef80299ce257d10c043913764abef83aceac5278a5bd243b1ee245b4e8331a9e13c774aa63c9cb604f86bdd
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

if(NOT VCPKG_CMAKE_SYSTEM_NAME)
    # Finish Directories
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/fann.dll ${CURRENT_PACKAGES_DIR}/bin/fann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/doublefann.dll ${CURRENT_PACKAGES_DIR}/bin/doublefann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/fixedfann.dll ${CURRENT_PACKAGES_DIR}/bin/fixedfann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/floatfann.dll ${CURRENT_PACKAGES_DIR}/bin/floatfann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/fann.lib ${CURRENT_PACKAGES_DIR}/lib/fann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/doublefann.lib ${CURRENT_PACKAGES_DIR}/lib/doublefann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/fixedfann.lib ${CURRENT_PACKAGES_DIR}/lib/fixedfann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/floatfann.lib ${CURRENT_PACKAGES_DIR}/lib/floatfann.lib)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/fann.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/doublefann.dll ${CURRENT_PACKAGES_DIR}/debug/bin/doublefann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/fixedfann.dll ${CURRENT_PACKAGES_DIR}/debug/bin/fixedfann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/floatfann.dll ${CURRENT_PACKAGES_DIR}/debug/bin/floatfann.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/fann.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/doublefann.lib ${CURRENT_PACKAGES_DIR}/debug/lib/doublefann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/fixedfann.lib ${CURRENT_PACKAGES_DIR}/debug/lib/fixedfann.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/floatfann.lib ${CURRENT_PACKAGES_DIR}/debug/lib/floatfann.lib)

    # Remove useless config file and include path
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
endif()

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(RENAME ${CURRENT_PACKAGES_DIR}/share/${PORT}/COPYING.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright)

vcpkg_copy_pdbs()
