vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeux/meshoptimizer
    REF "v${VERSION}"
    SHA512 23197a9dcd4cbbce625b9d142f2eaafc67c9cf92859f9a5ce94c4570fca8db07c97590d2737d97726dbf48e968f53c8d7dd26771678c2cade957c62a3600d88c
    HEAD_REF master
    PATCHES
        dependencies.diff
)

file(READ "${SOURCE_PATH}/CMakeLists.txt" _cmake)
string(REPLACE
    "set_target_properties(gltfpack PROPERTIES CXX_STANDARD 11)"
    "set_target_properties(gltfpack PROPERTIES CXX_STANDARD 11 NO_SYSTEM_FROM_IMPORTED ON)"
    _cmake "${_cmake}"
)
file(WRITE "${SOURCE_PATH}/CMakeLists.txt" "${_cmake}")

if ("gltfpack" IN_LIST FEATURES)
    # gltfpack needs symbols not in a released cgltf/fast-obj tag yet; patch local copies here
    # rather than the shared ports so other cgltf/fast-obj consumers are unaffected.
    file(COPY "${CURRENT_INSTALLED_DIR}/include/cgltf.h" "${CURRENT_INSTALLED_DIR}/include/fast_obj.h" DESTINATION "${SOURCE_PATH}/gltf")

    file(READ "${SOURCE_PATH}/gltf/cgltf.h" _cgltf)
    string(REPLACE
        "\tcgltf_meshopt_compression_filter_exponential,\n\tcgltf_meshopt_compression_filter_max_enum"
        "\tcgltf_meshopt_compression_filter_exponential,\n\tcgltf_meshopt_compression_filter_color,\n\tcgltf_meshopt_compression_filter_max_enum"
        _cgltf "${_cgltf}"
    )
    string(REPLACE
        "\t\t\tCGLTF_ASSERT_IF(mc->filter == cgltf_meshopt_compression_filter_quaternion && mc->stride != 8, cgltf_result_invalid_gltf);"
        "\t\t\tCGLTF_ASSERT_IF(mc->filter == cgltf_meshopt_compression_filter_quaternion && mc->stride != 8, cgltf_result_invalid_gltf);\n\t\t\tCGLTF_ASSERT_IF(mc->filter == cgltf_meshopt_compression_filter_color && mc->stride != 4 && mc->stride != 8, cgltf_result_invalid_gltf);"
        _cgltf "${_cgltf}"
    )
    string(REPLACE
        "\t\t\t\tout_meshopt_compression->filter = cgltf_meshopt_compression_filter_exponential;\n\t\t\t}\n\t\t\t++i;"
        "\t\t\t\tout_meshopt_compression->filter = cgltf_meshopt_compression_filter_exponential;\n\t\t\t}\n\t\t\telse if (cgltf_json_strcmp(tokens+i, json_chunk, \"COLOR\") == 0)\n\t\t\t{\n\t\t\t\tout_meshopt_compression->filter = cgltf_meshopt_compression_filter_color;\n\t\t\t}\n\t\t\t++i;"
        _cgltf "${_cgltf}"
    )
    file(WRITE "${SOURCE_PATH}/gltf/cgltf.h" "${_cgltf}")

    file(READ "${SOURCE_PATH}/gltf/fast_obj.h" _fastobj)
    string(REPLACE
        "    unsigned int*               face_materials;\n"
        "    unsigned int*               face_materials;\n    unsigned char*              face_lines;\n"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "const char* parse_face(fastObjData* data, const char* ptr)"
        "const char* parse_face(fastObjData* data, const char* ptr, unsigned char line)"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "    array_push(data->mesh->face_vertices, count);\n    array_push(data->mesh->face_materials, data->material);\n\n    data->group.face_count++;"
        "    array_push(data->mesh->face_vertices, count);\n    array_push(data->mesh->face_materials, data->material);\n\n    if (line || data->mesh->face_lines)\n    {\n        size_t skipped = array_size(data->mesh->face_vertices) - array_size(data->mesh->face_lines);\n        while (--skipped > 0)\n            array_push(data->mesh->face_lines, 0);\n\n        array_push(data->mesh->face_lines, line);\n    }\n\n    data->group.face_count++;"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "                p = parse_face(data, p);"
        "                p = parse_face(data, p, 0);"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "            break;\n\n        case 'o':"
        "            break;\n\n        case 'l':\n            p++;\n\n            switch (*p++)\n            {\n            case ' ':\n            case '\\t':\n                p = parse_face(data, p, 1);\n                break;\n\n            default:\n                p--; /* roll p++ back in case *p was a newline */\n            }\n            break;\n\n        case 'o':"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "    array_clean(m->face_materials);\n    array_clean(m->indices);"
        "    array_clean(m->face_materials);\n    array_clean(m->face_lines);\n    array_clean(m->indices);"
        _fastobj "${_fastobj}"
    )
    string(REPLACE
        "    m->face_materials = 0;\n    m->indices        = 0;"
        "    m->face_materials = 0;\n    m->face_lines     = 0;\n    m->indices        = 0;"
        _fastobj "${_fastobj}"
    )
    file(WRITE "${SOURCE_PATH}/gltf/fast_obj.h" "${_fastobj}")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gltfpack  MESHOPT_BUILD_GLTFPACK
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DMESHOPT_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}
    OPTIONS_DEBUG
        -DMESHOPT_BUILD_GLTFPACK=OFF # tool
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/meshoptimizer)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if ("gltfpack" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES gltfpack AUTO_CLEAN)
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
