include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 9176445fccead4f356d56040372f090f218158c1
        HEAD_REF main
        SHA512 7e88efe814fa165f1391b02a5414f02ffd953ee817cd89521888a492c7ff0e7e0cdb099b93b94f95722f9247501c29319c254773f7c55635d325a1ad9a08e28e
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
