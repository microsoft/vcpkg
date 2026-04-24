#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <mutex>
#include <optional>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#include "absl/cleanup/cleanup.h"
#include "api/create_modular_peer_connection_factory.h"
#include "api/enable_media_with_defaults.h"
#include "api/environment/environment_factory.h"
#include "api/jsep.h"
#include "api/make_ref_counted.h"
#include "api/media_stream_interface.h"
#include "api/notifier.h"
#include "api/peer_connection_interface.h"
#include "api/scoped_refptr.h"
#include "api/set_local_description_observer_interface.h"
#include "api/set_remote_description_observer_interface.h"
#include "api/video/i420_buffer.h"
#include "api/video/video_frame.h"
#include "api/video/video_sink_interface.h"
#include "modules/audio_device/include/fake_audio_device.h"
#include "rtc_base/checks.h"
#include "rtc_base/logging.h"
#include "rtc_base/ref_counted_object.h"
#include "rtc_base/ssl_adapter.h"
#include "rtc_base/thread.h"
#if defined(WEBRTC_WIN)
#include "rtc_base/win32_socket_init.h"
#endif

namespace {

using Clock = std::chrono::steady_clock;

class SyntheticVideoSource
    : public webrtc::Notifier<webrtc::VideoTrackSourceInterface> {
 public:
  SyntheticVideoSource()
      : state_(kLive), producer_([this] {
          uint32_t frame_index = 0;
          while (!stop_.load()) {
            BroadcastFrame(frame_index++);
            std::this_thread::sleep_for(std::chrono::milliseconds(100));
          }
        }) {}

  ~SyntheticVideoSource() override {
    stop_.store(true);
    if (producer_.joinable()) {
      producer_.join();
    }
    state_ = kEnded;
  }

  SourceState state() const override { return state_; }
  bool remote() const override { return false; }
  bool is_screencast() const override { return false; }
  std::optional<bool> needs_denoising() const override { return false; }
  bool GetStats(Stats* stats) override {
    if (stats == nullptr) {
      return false;
    }
    stats->input_width = kWidth;
    stats->input_height = kHeight;
    return true;
  }
  bool SupportsEncodedOutput() const override { return false; }
  void GenerateKeyFrame() override {}
  void AddEncodedSink(
      webrtc::VideoSinkInterface<webrtc::RecordableEncodedFrame>* sink)
      override {}
  void RemoveEncodedSink(
      webrtc::VideoSinkInterface<webrtc::RecordableEncodedFrame>* sink)
      override {}

  void AddOrUpdateSink(webrtc::VideoSinkInterface<webrtc::VideoFrame>* sink,
                       const webrtc::VideoSinkWants& wants) override {
    std::lock_guard<std::mutex> lock(mutex_);
    for (auto& entry : sinks_) {
      if (entry.sink == sink) {
        entry.wants = wants;
        return;
      }
    }
    sinks_.push_back({sink, wants});
  }

  void RemoveSink(
      webrtc::VideoSinkInterface<webrtc::VideoFrame>* sink) override {
    std::lock_guard<std::mutex> lock(mutex_);
    sinks_.erase(std::remove_if(sinks_.begin(), sinks_.end(),
                                [sink](const SinkEntry& entry) {
                                  return entry.sink == sink;
                                }),
                 sinks_.end());
  }

 private:
  struct SinkEntry {
    webrtc::VideoSinkInterface<webrtc::VideoFrame>* sink;
    webrtc::VideoSinkWants wants;
  };

  static constexpr int kWidth = 640;
  static constexpr int kHeight = 480;

  void BroadcastFrame(uint32_t frame_index) {
    auto buffer = webrtc::I420Buffer::Create(kWidth, kHeight);
    FillFrame(*buffer, frame_index);

    const int64_t timestamp_us =
        std::chrono::duration_cast<std::chrono::microseconds>(
            Clock::now().time_since_epoch())
            .count();

    webrtc::VideoFrame frame = webrtc::VideoFrame::Builder()
                                   .set_video_frame_buffer(buffer)
                                   .set_timestamp_us(timestamp_us)
                                   .set_rotation(webrtc::kVideoRotation_0)
                                   .build();

    std::vector<SinkEntry> sinks_copy;
    {
      std::lock_guard<std::mutex> lock(mutex_);
      sinks_copy = sinks_;
    }

    for (const SinkEntry& entry : sinks_copy) {
      if (entry.sink != nullptr) {
        entry.sink->OnFrame(frame);
      }
    }
  }

  static void FillPlane(uint8_t* data,
                        int stride,
                        int width,
                        int height,
                        uint8_t value) {
    for (int y = 0; y < height; ++y) {
      std::memset(data + y * stride, value, static_cast<size_t>(width));
    }
  }

  static void FillFrame(webrtc::I420Buffer& buffer, uint32_t frame_index) {
    const uint8_t luma = static_cast<uint8_t>((frame_index * 7) % 255);
    const uint8_t chroma_u =
        static_cast<uint8_t>(64 + ((frame_index * 5) % 128));
    const uint8_t chroma_v =
        static_cast<uint8_t>(192 - ((frame_index * 3) % 128));

    FillPlane(buffer.MutableDataY(), buffer.StrideY(), buffer.width(),
              buffer.height(), luma);
    FillPlane(buffer.MutableDataU(), buffer.StrideU(), (buffer.width() + 1) / 2,
              (buffer.height() + 1) / 2, chroma_u);
    FillPlane(buffer.MutableDataV(), buffer.StrideV(), (buffer.width() + 1) / 2,
              (buffer.height() + 1) / 2, chroma_v);
  }

  SourceState state_;
  std::atomic<bool> stop_{false};
  std::mutex mutex_;
  std::vector<SinkEntry> sinks_;
  std::thread producer_;
};

class FrameCounterSink final
    : public webrtc::VideoSinkInterface<webrtc::VideoFrame> {
 public:
  explicit FrameCounterSink(int target_frames)
      : target_frames_(target_frames) {}

  void OnFrame(const webrtc::VideoFrame& frame) override {
    std::lock_guard<std::mutex> lock(mutex_);
    if (frame_count_ == 0) {
      first_timestamp_us_ = frame.timestamp_us();
    }
    last_timestamp_us_ = frame.timestamp_us();
    ++frame_count_;
    RTC_LOG(LS_INFO) << "remote frame " << frame_count_
                     << " ts_us=" << frame.timestamp_us();
    if (frame_count_ >= target_frames_) {
      done_ = true;
      cv_.notify_all();
    }
  }

  bool WaitForFrames(std::chrono::seconds timeout) {
    std::unique_lock<std::mutex> lock(mutex_);
    return cv_.wait_for(lock, timeout, [this] { return done_; });
  }

  int frame_count() const {
    std::lock_guard<std::mutex> lock(mutex_);
    return frame_count_;
  }

 private:
  const int target_frames_;
  mutable std::mutex mutex_;
  std::condition_variable cv_;
  int frame_count_ = 0;
  int64_t first_timestamp_us_ = 0;
  int64_t last_timestamp_us_ = 0;
  bool done_ = false;
};

class CreateDescriptionObserver
    : public webrtc::CreateSessionDescriptionObserver {
 public:
  void OnSuccess(webrtc::SessionDescriptionInterface* desc) override {
    std::lock_guard<std::mutex> lock(mutex_);
    description_.reset(desc);
    done_ = true;
    cv_.notify_all();
  }

  void OnFailure(webrtc::RTCError error) override {
    std::lock_guard<std::mutex> lock(mutex_);
    error_ = error.message();
    done_ = true;
    cv_.notify_all();
  }

  std::unique_ptr<webrtc::SessionDescriptionInterface> Wait() {
    std::unique_lock<std::mutex> lock(mutex_);
    cv_.wait(lock, [this] { return done_; });
    if (!error_.empty()) {
      RTC_LOG(LS_ERROR) << "CreateSessionDescription failed: " << error_;
      return nullptr;
    }
    return std::move(description_);
  }

 private:
  std::mutex mutex_;
  std::condition_variable cv_;
  bool done_ = false;
  std::string error_;
  std::unique_ptr<webrtc::SessionDescriptionInterface> description_;
};

class SetLocalObserver : public webrtc::SetLocalDescriptionObserverInterface {
 public:
  void OnSetLocalDescriptionComplete(webrtc::RTCError error) override {
    std::lock_guard<std::mutex> lock(mutex_);
    error_ = std::move(error);
    done_ = true;
    cv_.notify_all();
  }

  bool Wait() {
    std::unique_lock<std::mutex> lock(mutex_);
    cv_.wait(lock, [this] { return done_; });
    if (!error_.ok()) {
      RTC_LOG(LS_ERROR) << "SetLocalDescription failed: " << error_.message();
    }
    return error_.ok();
  }

 private:
  std::mutex mutex_;
  std::condition_variable cv_;
  bool done_ = false;
  webrtc::RTCError error_ = webrtc::RTCError::OK();
};

class SetRemoteObserver : public webrtc::SetRemoteDescriptionObserverInterface {
 public:
  void OnSetRemoteDescriptionComplete(webrtc::RTCError error) override {
    std::lock_guard<std::mutex> lock(mutex_);
    error_ = std::move(error);
    done_ = true;
    cv_.notify_all();
  }

  bool Wait() {
    std::unique_lock<std::mutex> lock(mutex_);
    cv_.wait(lock, [this] { return done_; });
    if (!error_.ok()) {
      RTC_LOG(LS_ERROR) << "SetRemoteDescription failed: " << error_.message();
    }
    return error_.ok();
  }

 private:
  std::mutex mutex_;
  std::condition_variable cv_;
  bool done_ = false;
  webrtc::RTCError error_ = webrtc::RTCError::OK();
};

class PeerObserver;

class PeerHarness {
 public:
  PeerHarness(std::string name, FrameCounterSink* remote_sink)
      : name_(std::move(name)),
        observer_(std::make_unique<PeerObserver>(*this, remote_sink)) {}

  bool Initialize(webrtc::PeerConnectionFactoryInterface& factory);
  bool AddSyntheticTrack(webrtc::PeerConnectionFactoryInterface& factory);
  bool SetRemoteDescriptionCopy(webrtc::SdpType type, const std::string& sdp);
  bool AddIceCandidateCopy(const webrtc::IceCandidate& candidate);

  webrtc::PeerConnectionInterface* connection() const {
    return connection_.get();
  }
  void set_remote(PeerHarness* remote) { remote_ = remote; }

 private:
  class PeerObserver final : public webrtc::PeerConnectionObserver {
   public:
    PeerObserver(PeerHarness& owner, FrameCounterSink* remote_sink)
        : owner_(owner), remote_sink_(remote_sink) {}

    void OnSignalingChange(
        webrtc::PeerConnectionInterface::SignalingState new_state) override {
      RTC_LOG(LS_INFO) << owner_.name_ << " signaling="
                       << webrtc::PeerConnectionInterface::AsString(new_state);
    }

    void OnDataChannel(webrtc::scoped_refptr<webrtc::DataChannelInterface>
                           data_channel) override {
      (void)data_channel;
    }

    void OnIceGatheringChange(
        webrtc::PeerConnectionInterface::IceGatheringState new_state) override {
      RTC_LOG(LS_INFO) << owner_.name_ << " ice_gathering="
                       << webrtc::PeerConnectionInterface::AsString(new_state);
    }

    void OnConnectionChange(webrtc::PeerConnectionInterface::PeerConnectionState
                                new_state) override {
      RTC_LOG(LS_INFO) << owner_.name_ << " connection_state="
                       << webrtc::PeerConnectionInterface::AsString(new_state);
    }

    void OnIceCandidate(const webrtc::IceCandidate* candidate) override {
      if (candidate == nullptr || owner_.remote_ == nullptr) {
        return;
      }
      if (!owner_.remote_->AddIceCandidateCopy(*candidate)) {
        RTC_LOG(LS_ERROR) << owner_.name_ << " failed to forward ICE candidate";
      }
    }

    void OnTrack(webrtc::scoped_refptr<webrtc::RtpTransceiverInterface>
                     transceiver) override {
      if (remote_sink_ == nullptr) {
        return;
      }
      auto track = transceiver->receiver()->track();
      if (track &&
          track->kind() == webrtc::MediaStreamTrackInterface::kVideoKind) {
        static_cast<webrtc::VideoTrackInterface*>(track.get())
            ->AddOrUpdateSink(remote_sink_, webrtc::VideoSinkWants());
        RTC_LOG(LS_INFO) << owner_.name_ << " attached remote video sink";
      }
    }

   private:
    PeerHarness& owner_;
    FrameCounterSink* remote_sink_;
  };

  std::string name_;
  std::unique_ptr<PeerObserver> observer_;
  PeerHarness* remote_ = nullptr;
  webrtc::scoped_refptr<webrtc::PeerConnectionInterface> connection_;
  webrtc::scoped_refptr<SyntheticVideoSource> source_;
};

bool PeerHarness::Initialize(webrtc::PeerConnectionFactoryInterface& factory) {
  webrtc::PeerConnectionInterface::RTCConfiguration config;
  config.sdp_semantics = webrtc::SdpSemantics::kUnifiedPlan;

  webrtc::PeerConnectionDependencies deps(observer_.get());
  auto result = factory.CreatePeerConnectionOrError(config, std::move(deps));
  if (!result.ok()) {
    RTC_LOG(LS_ERROR) << name_ << " CreatePeerConnection failed: "
                      << result.error().message();
    return false;
  }
  connection_ = result.MoveValue();
  return true;
}

bool PeerHarness::AddSyntheticTrack(
    webrtc::PeerConnectionFactoryInterface& factory) {
  source_ = webrtc::make_ref_counted<SyntheticVideoSource>();
  auto track = factory.CreateVideoTrack(source_, "synthetic-video");
  auto result = connection_->AddTrack(track, {"synthetic-stream"});
  if (!result.ok()) {
    RTC_LOG(LS_ERROR) << name_
                      << " AddTrack failed: " << result.error().message();
    return false;
  }
  return true;
}

bool PeerHarness::SetRemoteDescriptionCopy(webrtc::SdpType type,
                                           const std::string& sdp) {
  webrtc::SdpParseError error;
  auto desc = webrtc::CreateSessionDescription(type, sdp, &error);
  if (!desc) {
    RTC_LOG(LS_ERROR) << name_
                      << " failed to parse remote SDP: " << error.description;
    return false;
  }
  auto observer = webrtc::make_ref_counted<SetRemoteObserver>();
  connection_->SetRemoteDescription(std::move(desc), observer);
  return observer->Wait();
}

bool PeerHarness::AddIceCandidateCopy(const webrtc::IceCandidate& candidate) {
  auto copy = webrtc::CreateIceCandidate(candidate.sdp_mid(),
                                         candidate.sdp_mline_index(),
                                         candidate.ToString(), nullptr);
  return copy != nullptr && connection_->AddIceCandidate(copy);
}

bool ApplyLocalDescription(
    webrtc::PeerConnectionInterface& connection,
    std::unique_ptr<webrtc::SessionDescriptionInterface> desc) {
  auto observer = webrtc::make_ref_counted<SetLocalObserver>();
  connection.SetLocalDescription(std::move(desc), observer);
  return observer->Wait();
}

std::unique_ptr<webrtc::SessionDescriptionInterface> CreateOffer(
    webrtc::PeerConnectionInterface& connection) {
  auto observer = webrtc::make_ref_counted<CreateDescriptionObserver>();
  connection.CreateOffer(observer.get(), {});
  return observer->Wait();
}

std::unique_ptr<webrtc::SessionDescriptionInterface> CreateAnswer(
    webrtc::PeerConnectionInterface& connection) {
  auto observer = webrtc::make_ref_counted<CreateDescriptionObserver>();
  connection.CreateAnswer(observer.get(), {});
  return observer->Wait();
}

bool Negotiate(PeerHarness& caller, PeerHarness& callee) {
  auto offer = CreateOffer(*caller.connection());
  if (!offer) {
    return false;
  }

  std::string offer_sdp;
  if (!offer->ToString(&offer_sdp)) {
    RTC_LOG(LS_ERROR) << "failed to serialize offer";
    return false;
  }

  if (!ApplyLocalDescription(*caller.connection(), std::move(offer))) {
    return false;
  }
  if (!callee.SetRemoteDescriptionCopy(webrtc::SdpType::kOffer, offer_sdp)) {
    return false;
  }

  auto answer = CreateAnswer(*callee.connection());
  if (!answer) {
    return false;
  }

  std::string answer_sdp;
  if (!answer->ToString(&answer_sdp)) {
    RTC_LOG(LS_ERROR) << "failed to serialize answer";
    return false;
  }

  if (!ApplyLocalDescription(*callee.connection(), std::move(answer))) {
    return false;
  }
  if (!caller.SetRemoteDescriptionCopy(webrtc::SdpType::kAnswer, answer_sdp)) {
    return false;
  }

  return true;
}

}  // namespace

int main() {
  webrtc::LogMessage::SetLogToStderr(true);
  webrtc::LogMessage::LogToDebug(webrtc::LS_INFO);
  webrtc::LogMessage::LogTimestamps();
  webrtc::LogMessage::LogThreads();

#if defined(WEBRTC_WIN)
  webrtc::WinsockInitializer winsock_init;
  if (winsock_init.error() != 0) {
    RTC_LOG(LS_ERROR) << "failed to initialize Winsock: "
                      << winsock_init.error();
    return 1;
  }
#endif
  if (!webrtc::InitializeSSL()) {
    RTC_LOG(LS_ERROR) << "failed to initialize SSL";
    return 1;
  }
  auto ssl_cleanup = absl::Cleanup([] { webrtc::CleanupSSL(); });

  auto network_thread = webrtc::Thread::CreateWithSocketServer();
  auto worker_thread = webrtc::Thread::Create();
  auto signaling_thread = webrtc::Thread::Create();

  network_thread->SetName("webrtc-sample-network", nullptr);
  worker_thread->SetName("webrtc-sample-worker", nullptr);
  signaling_thread->SetName("webrtc-sample-signaling", nullptr);

  if (!network_thread->Start() || !worker_thread->Start() ||
      !signaling_thread->Start()) {
    RTC_LOG(LS_ERROR) << "failed to start WebRTC threads";
    return 1;
  }

  webrtc::PeerConnectionFactoryDependencies deps;
  deps.env = webrtc::CreateEnvironment();
  deps.network_thread = network_thread.get();
  deps.worker_thread = worker_thread.get();
  deps.signaling_thread = signaling_thread.get();
  webrtc::EnableMediaWithDefaults(deps);
  deps.adm = webrtc::scoped_refptr<webrtc::AudioDeviceModule>(
      new webrtc::RefCountedObject<webrtc::FakeAudioDeviceModule>());

  auto factory = webrtc::CreateModularPeerConnectionFactory(std::move(deps));
  if (!factory) {
    RTC_LOG(LS_ERROR) << "failed to create PeerConnectionFactory";
    return 1;
  }

  webrtc::PeerConnectionFactoryInterface::Options options;
  factory->SetOptions(options);

  FrameCounterSink remote_sink(10);
  PeerHarness caller("caller", nullptr);
  PeerHarness callee("callee", &remote_sink);
  auto close_peers = absl::Cleanup([&] {
    if (caller.connection() != nullptr) {
      caller.connection()->Close();
    }
    if (callee.connection() != nullptr) {
      callee.connection()->Close();
    }
  });
  caller.set_remote(&callee);
  callee.set_remote(&caller);

  if (!caller.Initialize(*factory) || !callee.Initialize(*factory)) {
    return 1;
  }
  if (!caller.AddSyntheticTrack(*factory)) {
    return 1;
  }
  if (!Negotiate(caller, callee)) {
    return 1;
  }

  if (!remote_sink.WaitForFrames(std::chrono::seconds(10))) {
    RTC_LOG(LS_ERROR) << "timed out waiting for remote video; frames="
                      << remote_sink.frame_count();
    return 1;
  }

  RTC_LOG(LS_INFO) << "success: remote frames=" << remote_sink.frame_count();
  return 0;
}
