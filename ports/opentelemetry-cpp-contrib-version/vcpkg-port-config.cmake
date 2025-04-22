include_guard(GLOBAL)

function(clone_opentelemetry_cpp_contrib CONTRIB_SOURCE_PATH)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO open-telemetry/opentelemetry-cpp-contrib
        REF 6392b5ff2ebd134e3aa359adc97a2ed37888977c
        HEAD_REF main
        SHA512 8318031c203691e6fa4ffc363d3a37642b2705898bd25b23acd211489c2006c268c3e333c7bef8685d762a8b31b762b96f4d175f6edb9eaf29047852c568e31f
    )
    set(${CONTRIB_SOURCE_PATH} ${SOURCE_PATH} CACHE INTERNAL "")
endfunction()
