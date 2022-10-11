vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanopb/nanopb
    REF 0.4.5
    SHA512 2f24308440bd961a94449e253627fbe38f6c5217cd70c57e9b3ab702da3c2df03b087ccdd62518940acf6b480a1dbb440ca5681f1766a17b199010d3df7b17a1
    HEAD_REF master
    PATCHES 
        fix-python.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" nanopb_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" nanopb_STATIC_LINKING)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        generator nanopb_BUILD_GENERATOR
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPython_EXECUTABLE=${PYTHON3}
        -Dnanopb_BUILD_RUNTIME=ON
        -DBUILD_STATIC_LIBS=${nanopb_BUILD_STATIC_LIBS}
        -Dnanopb_MSVC_STATIC_RUNTIME=${nanopb_STATIC_LINKING}
        -Dnanopb_PROTOC_PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(nanopb_BUILD_GENERATOR)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/nanopb_generator.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    if(WIN32)
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/Lib/site-packages/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/site-packages")
    else()
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
endif()

if(nanopb_BUILD_STATIC_LIBS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
