include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lballabio/QuantLib
    REF 33d92b874836bc0b955def9fd3f14626a9dab829
    SHA512 fd129d71569a6d99ee1b818f942875a535a6e1426847bf3bdea5ad555d8934532cf45261cd38dadaeddaefb489cd02f08ab8563059685e5dde82fc1df4186a94
    HEAD_REF master
    PATCHES
        disable-examples-tests.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" USE_BOOST_DYNAMIC_LIBRARIES)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DUSE_BOOST_DYNAMIC_LIBRARIES=${USE_BOOST_DYNAMIC_LIBRARIES}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.TXT ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
