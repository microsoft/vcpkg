if(WIN32)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO            orlp/${PORT}
    REF             b1f19fab4aebe607805620d25a5e42566ce46a0e
    SHA512          fcbeba58591543304dd93ae7c1b62a720d89c80c4c07c323eabb6e1f41b93562660181973bda345976e5361e925f243ba9abaec19fc8a05235011957367c6e7e
    HEAD_REF        master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt"
     DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
        SOURCE_PATH "${SOURCE_PATH}"
        OPTIONS
        "-DVERSION=${VERSION}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "Zlib")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include")
