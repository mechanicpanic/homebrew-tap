class Lampa < Formula
  desc "Your Mac's music to Yeelight and WiZ bulbs in real time, with a cozy TUI"
  homepage "https://github.com/mechanicpanic/lampa"
  url "https://github.com/mechanicpanic/lampa/archive/refs/tags/v0.1.4.tar.gz"
  sha256 "b95656b882294e8aba288bab0d7635b9a96b9a7b9fc6fbbb1e0715fad05e84a3"
  license "MIT"
  head "https://github.com/mechanicpanic/lampa.git", branch: "master"

  depends_on "go" => :build
  depends_on macos: :sonoma # Core Audio process taps need macOS 14.4+

  def install
    # Core Audio tap helper (Swift) and the Now Playing library, kept out of PATH.
    system "swift", "build", "--disable-sandbox", "-c", "release", "--package-path", "tap"
    libexec.install "tap/.build/release/lampa-tap"
    system ENV.cc, "-dynamiclib", "-O2", "-fobjc-arc", "-framework", "Foundation",
           "tap/nowplaying/nowplaying.m", "-o", libexec/"libnowplaying.dylib"

    system "go", "build", *std_go_args, "./cmd/lampa"
  end

  def caveats
    <<~EOS
      Find your lamps and save them to ~/.config/lampa/config.toml:
        lampa discover --save
      Then run `lampa`. On first run macOS asks to allow audio recording for
      your terminal (System Settings → Privacy & Security → Screen & System
      Audio Recording).
    EOS
  end

  test do
    assert_match "-dry", shell_output("#{bin}/lampa -h 2>&1")
    assert_path_exists libexec/"lampa-tap"
    assert_path_exists libexec/"libnowplaying.dylib"
  end
end
