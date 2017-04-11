#pragma once

#include <string>

namespace vcpkg::Metrics
{
    void set_send_metrics(bool should_send_metrics);
    void set_print_metrics(bool should_print_metrics);
    void set_user_information(const std::string& user_id, const std::string& first_use_time);
    void init_user_information(std::string& user_id, std::string& first_use_time);

    void track_metric(const std::string& name, double value);
    void track_property(const std::string& name, const std::string& value);
    void track_property(const std::string& name, const std::wstring& value);
    bool get_compiled_metrics_enabled();
    std::wstring get_SQM_user();

    void upload(const std::string& payload);
    void flush();
}
