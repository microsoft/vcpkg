include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenKinect/libfreenect2
    REF v0.2.0
    SHA512 3525e3f21462cecd3b198f64545786ffddc2cafdfd8146e5a46f0300b83f29f1ad0739618a07ab195c276149d7e2e909f7662e2d379a2880593cac75942b0666
    HEAD_REF master
    PATCHES
        TurboJPEG.patch
)

file(READ ${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake FINDLIBUSB)
string(REPLACE "(WIN32)"
               "(WIN32_DISABLE)" FINDLIBUSB "${FINDLIBUSB}")
file(WRITE ${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake "${FINDLIBUSB}")

file(READ ${SOURCE_PATH}/examples/CMakeLists.txt EXAMPLECMAKE)
string(REPLACE "(WIN32)"
               "(WIN32_DISABLE)" EXAMPLECMAKE "${EXAMPLECMAKE}")
file(WRITE ${SOURCE_PATH}/examples/CMakeLists.txt "${EXAMPLECMAKE}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_CUDA=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/freenect2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# The cmake config is actually called freenect2Config.cmake instead of libfreenect2Config.cmake ...
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libfreenect2 ${CURRENT_PACKAGES_DIR}/share/freenect2)

# license file needs to be in share/libfreenect2 otherwise vcpkg will complain
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share/libfreenect2/)
file(COPY ${SOURCE_PATH}/GPL2 DESTINATION ${CURRENT_PACKAGES_DIR}/share/libfreenect2/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libfreenect2/GPL2 ${CURRENT_PACKAGES_DIR}/share/libfreenect2/copyright)
