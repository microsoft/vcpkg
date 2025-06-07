include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF dcff8837c588bbbb2ac8bc86842989e24a5eacff
        HEAD_REF main
        SHA512 506c9177c757ff7b832972bae4c822315d59991ae104e876104d4a06c238dde935b4bbef59b62c6fada220fcdf8c5315aa3dbecd62888b41d8d2f3e0730fdba8
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
