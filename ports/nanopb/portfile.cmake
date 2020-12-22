vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

message(WARNING "\
The nanopb's code generator is not installed as part of the installation \
currently. So you have to run the code generator manually."
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nanopb/nanopb
    REF d1305ddef1c18b4cb33992254494ccd255701aaa
    SHA512 70e588b0ff13846005658a9fafe57551dc2c126a32f351fe0b6c166c142c42b3bcc44567288f609f2f3a5adc1fe1bf1c585fec8c5fe90817b5b3ab47955aa1fc
    HEAD_REF master
)

string(COMPARE EQUAL ${VCPKG_LIBRARY_LINKAGE} "static" BUILD_STATIC_LIBS)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dnanopb_BUILD_RUNTIME=ON
        -Dnanopb_BUILD_GENERATOR=OFF
        -DBUILD_STATIC_LIBS=${BUILD_STATIC_LIBS}
        -Dnanopb_MSVC_STATIC_RUNTIME=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
