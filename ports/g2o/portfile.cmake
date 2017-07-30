include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO RainerKuemmerle/g2o
    REF 20170730_git
    SHA512 a85e3f79e6a8bd0f81a9a1a7a01227779100d9f4ebd0ae9c03537bbdcc246018f292b53045f027bbe28ecf63b98de2f22f5528c992c93c9790eb6a3a40995903
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    foreach(HEADER g2o/apps/g2o_hierarchical/g2o_hierarchical_api.h
                   g2o/types/slam3d_addons/g2o_types_slam3d_addons_api.h
                   g2o/apps/g2o_cli/g2o_cli_api.h
                   g2o/apps/g2o_simulator/g2o_simulator_api.h
                   g2o/core/g2o_core_api.h
                   g2o/solvers/csparse/g2o_csparse_api.h
                   g2o/stuff/g2o_stuff_api.h
                   g2o/types/icp/g2o_types_icp_api.h
                   g2o/solvers/slam2d_linear/g2o_slam2d_linear_api.h
                   g2o/types/data/g2o_types_data_api.h
                   g2o/types/sclam2d/g2o_types_sclam2d_api.h
                   g2o/types/slam2d/g2o_types_slam2d_api.h
                   g2o/types/slam3d/g2o_types_slam3d_api.h
                   g2o/types/sba/g2o_types_sba_api.h
                   g2o/types/slam2d_addons/g2o_types_slam2d_addons_api.h
                   g2o/solvers/csparse/g2o_csparse_extension_api.h
                   g2o/core/robust_kernel_factory.h
                   g2o/stuff/opengl_primitives.h
                   g2o/core/optimization_algorithm_factory.h
                   g2o/core/factory.h)
        file(READ ${CURRENT_PACKAGES_DIR}/include/${HEADER} HEADER_CONTENTS)
        string(REPLACE "#ifdef G2O_SHARED_LIBS" "#if 1" HEADER_CONTENTS "${HEADER_CONTENTS}")
        file(WRITE ${CURRENT_PACKAGES_DIR}/include/${HEADER} "${HEADER_CONTENTS}")
    endforeach()
endif()

file(GLOB EXE ${CURRENT_PACKAGES_DIR}/bin/*.exe)
file(GLOB DEBUG_EXE ${CURRENT_PACKAGES_DIR}/debug/bin/*.exe)
file(REMOVE ${EXE})
file(REMOVE ${DEBUG_EXE})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/doc/license-bsd.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/g2o/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/g2o/license-bsd.txt ${CURRENT_PACKAGES_DIR}/share/g2o/copyright)
