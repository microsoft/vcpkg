#pragma once

#include <vcpkg/base/util.h>

#include <string>

namespace vcpkg::Metrics
{
    struct Metrics : Util::ResourceBase
    {
        void set_send_metrics(bool should_send_metrics);
        void set_print_metrics(bool should_print_metrics);
        void set_disabled(bool disabled);
        void set_user_information(const std::string& user_id, const std::string& first_use_time);
        static void init_user_information(std::string& user_id, std::string& first_use_time);

        void track_metric(const std::string& name, double value);
        void track_buildtime(const std::string& name, double value);
        void track_property(const std::string& name, const std::string& value);

        bool metrics_enabled();

        void upload(const std::string& payload);
        void flush();
    };

    extern Util::LockGuarded<Metrics> g_metrics;

    std::string get_MAC_user();
}
