# Homebrew formula for Button Heist CLI + MCP server.
#
# Formula shape lives here. Release artifact names and repository constants
# live in scripts/release-contract.sh. The release workflow renders this into
# TheButtonHeist/homebrew-tap with real SHA-256 values.
#
# Users install with:
#   brew install TheButtonHeist/tap/buttonheist

class Buttonheist < Formula
  desc "Give AI agents full programmatic control of iOS apps"
  homepage "https://github.com/TheButtonHeist/TheButtonHeist"
  version "0.7.0"

  url "https://github.com/TheButtonHeist/TheButtonHeist/releases/download/v0.7.0/buttonheist-0.7.0-macos.tar.gz"
  sha256 "b91f76aa33d6bfff2a55ac117d2c9e7c878f3690fe6868f9d061d75479169789"

  resource "mcp" do
    url "https://github.com/TheButtonHeist/TheButtonHeist/releases/download/v0.7.0/buttonheist-mcp-0.7.0-macos.tar.gz"
    sha256 "82ed501c37af1feb225062a3f271d7143b31eff0198be47e881d955184ac5e96"
  end

  depends_on :macos
  on_macos do
    depends_on macos: :sonoma
  end
  depends_on arch: :arm64

  def install
    bin.install "buttonheist"
    lib.install "ThePlans" if (buildpath/"ThePlans").exist?
    resource("mcp").stage { bin.install "buttonheist-mcp" }
  end

  def caveats
    <<~EOS
      MCP server is installed at:
        #{opt_bin}/buttonheist-mcp

      Add to your project's .mcp.json:
        {
          "mcpServers": {
            "buttonheist": {
              "command": "#{opt_bin}/buttonheist-mcp",
              "args": []
            }
          }
        }
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/buttonheist --version")
    assert_predicate bin/"buttonheist-mcp", :exist?
    assert_predicate bin/"buttonheist-mcp", :executable?
    assert_predicate lib/"ThePlans/arm64-apple-macosx/release/Modules/ThePlans.swiftinterface", :exist?
    refute_predicate lib/"ThePlans/arm64-apple-macosx/release/Modules/ThePlans.swiftmodule", :exist?
    assert_predicate lib/"ThePlans/arm64-apple-macosx/release/description.json", :exist?
  end
end
