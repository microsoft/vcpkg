vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenKinect/libfreenect2
    REF v0.2.0
    SHA512 3525e3f21462cecd3b198f64545786ffddc2cafdfd8146e5a46f0300b83f29f1ad0739618a07ab195c276149d7e2e909f7662e2d379a2880593cac75942b0666
    HEAD_REF master
    PATCHES fix-dependency-libusb.patch
)

file(READ ${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake FINDLIBUSB)
string(REPLACE "(WIN32)"
               "(WIN32_DISABLE)" FINDLIBUSB "${FINDLIBUSB}")
file(WRITE ${SOURCE_PATH}/cmake_modules/FindLibUSB.cmake "${FINDLIBUSB}")

file(READ ${SOURCE_PATH}/examples/CMakeLists.txt EXAMPLECMAKE)
string(REPLACE "(WIN32)"
               "(WIN32_DISABLE)" EXAMPLECMAKE "${EXAMPLECMAKE}")
file(WRITE ${SOURCE_PATH}/examples/CMakeLists.txt "${EXAMPLECMAKE}")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    opengl     ENABLE_OPENGL
    opencl     ENABLE_OPENCL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_CUDA=OFF
        # FEATURES
        ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/freenect2 TARGET_PATH share/freenect2)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/GPL2 DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fixup_pkgconfig()
