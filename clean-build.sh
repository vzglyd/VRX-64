#!/bin/bash
# VRX-64 build cleanup and maintenance script
# Usage: 
#   ./clean-build.sh          - Clean and rebuild release
#   ./clean-build.sh dev      - Clean and rebuild debug
#   ./clean-build.sh --clean  - Just clean, don't rebuild

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

clean() {
    echo "🧹 Cleaning build artifacts..."
    cargo clean
    echo "✅ Cleaned. Freed up $(du -sh target 2>/dev/null | cut -f1 || echo 'all') space."
}

build_release() {
    echo "🔨 Building release binaries (optimized for size)..."
    cargo build --release
    echo "✅ Release build complete!"
    echo "📊 Target directory size: $(du -sh target 2>/dev/null | cut -f1)"
}

build_dev() {
    echo "🔨 Building debug binaries..."
    cargo build
    echo "✅ Debug build complete!"
    echo "📊 Target directory size: $(du -sh target 2>/dev/null | cut -f1)"
}

show_size() {
    echo "📊 Current target directory size:"
    if [ -d "target" ]; then
        du -sh target
        echo ""
        echo "Breakdown by profile:"
        du -sh target/debug 2>/dev/null || true
        du -sh target/release 2>/dev/null || true
    else
        echo "  No target directory found."
    fi
}

# Parse arguments
case "${1:-}" in
    --clean|-c)
        clean
        ;;
    dev|debug)
        clean
        build_dev
        ;;
    --size|-s)
        show_size
        ;;
    --help|-h)
        echo "Usage: $0 [option]"
        echo ""
        echo "Options:"
        echo "  (no args)    Clean and build release"
        echo "  dev/debug    Clean and build debug"
        echo "  --clean/-c   Just clean, don't rebuild"
        echo "  --size/-s    Show current build size"
        echo "  --help/-h    Show this help message"
        ;;
    "")
        clean
        build_release
        ;;
    *)
        echo "Unknown option: $1"
        echo "Use --help for usage information."
        exit 1
        ;;
esac
