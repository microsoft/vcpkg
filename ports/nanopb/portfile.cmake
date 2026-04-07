vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanopb/nanopb
    REF ${VERSION}
    SHA512 1580c94d558f707c88d8d2ddf4aa3bf4ef244ddc07b13e02de7124da8d156fb30a6999bb3c54ff0497abb033e498fb85ea671774f2fb817f55fa64937f537c77
    HEAD_REF master
    PATCHES 
        fix-cmakelist.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" nanopb_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" nanopb_STATIC_LINKING)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        generator nanopb_BUILD_GENERATOR
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DPython_EXECUTABLE=${PYTHON3}
        -Dnanopb_BUILD_RUNTIME=ON
        -DBUILD_STATIC_LIBS=${nanopb_BUILD_STATIC_LIBS}
        -Dnanopb_MSVC_STATIC_RUNTIME=${nanopb_STATIC_LINKING}
        "-Dnanopb_PROTOC_PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}"
        ${FEATURE_OPTIONS}
        -DCMAKE_INSTALL_DATADIR=share/${PORT}
    MAYBE_UNUSED_VARIABLES
        Python_EXECUTABLE
        nanopb_PROTOC_PATH
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

if(nanopb_BUILD_GENERATOR)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/generator/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    if(VCPKG_TARGET_IS_WINDOWS)
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/nanopb_generator.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    else()
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/nanopb_generator" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

if(nanopb_BUILD_STATIC_LIBS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
