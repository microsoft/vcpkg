#pragma once

#include <string>

namespace vcpkg::Metrics
{
    void SetSendMetrics(bool should_send_metrics);
    void SetPrintMetrics(bool should_print_metrics);
    void SetUserInformation(const std::string& user_id, const std::string& first_use_time);
    void InitUserInformation(std::string& user_id, std::string& first_use_time);

    void TrackMetric(const std::string& name, double value);
    void TrackProperty(const std::string& name, const std::string& value);
    void TrackProperty(const std::string& name, const std::wstring& value);
    bool GetCompiledMetricsEnabled();
    std::wstring GetSQMUser();

    void Upload(const std::string& payload);
    void Flush();
}
