#include <vcpkg/fwd/vcpkgpaths.h>

namespace vcpkg::Versions
{
    struct Version;

    void fetch_port_commit_id(const vcpkg::VcpkgPaths& paths,
                              const std::string& port_name,
                              const std::string& commit_id);

    void fetch_port_version(const vcpkg::VcpkgPaths& paths,
                            const std::string& port_name,
                            const vcpkg::Versions::Version& version);

    Optional<vcpkg::Versions::Version> fetch_port_baseline(const vcpkg::VcpkgPaths& paths,
                                                           const std::string& port_name,
                                                           const std::string& baseline);
}