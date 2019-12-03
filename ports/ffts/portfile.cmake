vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO anthonix/ffts
    REF fe86885ecafd0d16eb122f3212403d1d5a86e24e
    SHA512 3d96705a22948cb1b06b32bcad2fcaf516fb9f5da594e8626879be122edc29cd5b1c2eec3a493f4e98b49034b0a14d179765716ac59ba12bab6b4b388d299a66
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ENABLE_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" ENABLE_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DENABLE_NEON=OFF
        -DENABLE_VFP=OFF
        -DDISABLE_DYNAMIC_CODE=OFF
        -DGENERATE_POSITION_INDEPENDENT_CODE=${ENABLE_SHARED}
        -DENABLE_SHARED=${ENABLE_SHARED}
        -DENABLE_STATIC=${ENABLE_STATIC}
)

vcpkg_install_cmake()

if(VCPKG_TARGET_IS_WINDOWS AND ENABLE_SHARED)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/include/ffts/ffts.h
        "defined(FFTS_SHARED)"
        "1 //defined(FFTS_SHARED)"
    )

    file(COPY
        ${CURRENT_PACKAGES_DIR}/debug/lib/fftsd.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
    )
    file(COPY
        ${CURRENT_PACKAGES_DIR}/lib/ffts.dll
        DESTINATION ${CURRENT_PACKAGES_DIR}/bin
    )

    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/debug/lib/fftsd.dll
        ${CURRENT_PACKAGES_DIR}/lib/ffts.dll
    )
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
