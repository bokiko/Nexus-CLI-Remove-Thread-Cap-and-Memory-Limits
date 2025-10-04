#!/bin/bash

################################################################################
# 🚀 NEXUS CLI UNLEASH SCRIPT
# Automatically removes thread caps and memory limits from ANY Nexus CLI version
# 
# What this does:
# - Detects your Nexus CLI version automatically
# - Removes the 75% CPU limit (new versions) or 8-thread cap (old versions)
# - Disables memory checks that reduce performance
# - Builds and installs the optimized version
# - Creates backups so you can restore anytime
#
# Usage: bash nexus-unleash.sh
# Requirements: Ubuntu/Linux, at least 16GB RAM recommended
################################################################################

# Color codes for pretty output (makes it easier to read)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored messages
print_header() {
    echo -e "\n${PURPLE}========================================${NC}"
    echo -e "${PURPLE}$1${NC}"
    echo -e "${PURPLE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

################################################################################
# STEP 1: WELCOME & SYSTEM CHECK
################################################################################

print_header "🚀 NEXUS CLI UNLEASH - REMOVE THREAD LIMITS"

echo "This script will:"
echo "  1. Clone/update Nexus CLI source code"
echo "  2. Detect your version automatically"
echo "  3. Remove artificial thread and memory limits"
echo "  4. Build and install the optimized version"
echo ""
print_warning "Make sure you have at least 16GB RAM"
print_warning "Each thread uses ~3-4GB of memory"
echo ""

# Get system info
TOTAL_CORES=$(nproc)
TOTAL_RAM_GB=$(free -g | awk '/^Mem:/{print $2}')

print_info "Your system: ${TOTAL_CORES} CPU cores, ${TOTAL_RAM_GB}GB RAM"

# Calculate safe thread count based on RAM
SAFE_THREADS=$((TOTAL_RAM_GB / 4))
if [ $SAFE_THREADS -gt $TOTAL_CORES ]; then
    SAFE_THREADS=$TOTAL_CORES
fi

print_info "Recommended max threads: ${SAFE_THREADS} (based on your RAM)"
echo ""

read -p "Continue? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Cancelled by user"
    exit 1
fi

################################################################################
# STEP 2: INSTALL RUST (if needed)
################################################################################

print_header "📦 CHECKING RUST INSTALLATION"

if ! command -v cargo &> /dev/null; then
    print_warning "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
    print_success "Rust installed successfully"
else
    print_success "Rust is already installed"
    rustup update > /dev/null 2>&1
    print_success "Rust updated to latest version"
fi

################################################################################
# STEP 3: CLONE/UPDATE NEXUS CLI
################################################################################

print_header "📥 GETTING NEXUS CLI SOURCE CODE"

cd ~

if [ -d "nexus-cli" ]; then
    print_info "nexus-cli directory exists. Updating..."
    cd nexus-cli
    git fetch origin
    git reset --hard origin/main
    print_success "Updated to latest version"
else
    print_info "Cloning Nexus CLI repository..."
    git clone https://github.com/nexus-xyz/nexus-cli.git
    cd nexus-cli
    print_success "Cloned successfully"
fi

################################################################################
# STEP 4: AUTO-DETECT VERSION & FILE LOCATIONS
################################################################################

print_header "🔍 DETECTING VERSION & FILE STRUCTURE"

# Search for the setup file
SETUP_FILE=""

# Try new structure first (v0.10.17+)
if [ -f "clients/cli/src/session/setup.rs" ]; then
    SETUP_FILE="clients/cli/src/session/setup.rs"
    BUILD_DIR="clients/cli"
    BINARY_NAME="nexus-network"
    VERSION_TYPE="NEW (v0.10.17+)"
    print_success "Detected NEW version structure"
elif [ -f "src/session/setup.rs" ]; then
    SETUP_FILE="src/session/setup.rs"
    BUILD_DIR="."
    BINARY_NAME="nexus-cli"
    VERSION_TYPE="OLD (v0.10.0-16)"
    print_success "Detected OLD version structure"
else
    # Search for any file containing thread limits
    print_info "Searching for setup files..."
    SETUP_FILE=$(find . -name "*.rs" -type f -exec grep -l "num_workers" {} \; | grep -E "(setup|session)" | head -1)
    
    if [ -z "$SETUP_FILE" ]; then
        print_error "Could not find setup.rs file!"
        print_error "This version might be too old or have a different structure."
        exit 1
    fi
    
    BUILD_DIR=$(dirname $(find . -name "Cargo.toml" | grep -E "(cli|nexus)" | head -1))
    BINARY_NAME="nexus-cli"
    VERSION_TYPE="UNKNOWN (auto-detected)"
    print_success "Found setup file at: $SETUP_FILE"
fi

print_info "Version: ${VERSION_TYPE}"
print_info "Setup file: ${SETUP_FILE}"
print_info "Build directory: ${BUILD_DIR}"
print_info "Binary name: ${BINARY_NAME}"

################################################################################
# STEP 5: BACKUP ORIGINAL FILE
################################################################################

print_header "💾 CREATING BACKUP"

BACKUP_FILE="${SETUP_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
cp "$SETUP_FILE" "$BACKUP_FILE"
print_success "Backup created: $BACKUP_FILE"

################################################################################
# STEP 6: MODIFY THE CODE TO REMOVE LIMITS
################################################################################

print_header "🔧 REMOVING THREAD LIMITS & MEMORY CHECKS"

# Create a temporary file for modifications
TEMP_FILE=$(mktemp)

# Read the file and apply modifications
print_info "Analyzing code..."

# Check what kind of limits are present
if grep -q "0.75" "$SETUP_FILE"; then
    print_info "Found 75% CPU limit (NEW VERSION)"
    HAS_75_LIMIT=true
else
    HAS_75_LIMIT=false
fi

if grep -q "clamp(1, 8)" "$SETUP_FILE"; then
    print_info "Found 8-thread hard cap (OLD VERSION)"
    HAS_8_CAP=true
else
    HAS_8_CAP=false
fi

# Apply modifications
print_info "Applying modifications..."

cat "$SETUP_FILE" | \
    # Remove 75% CPU limit (change 0.75 to 1.0)
    sed 's/\* 0\.75/\* 1.0/g' | \
    # Remove 8-thread hard cap (change clamp(1, 8) to max(1))
    sed 's/\.clamp(1, 8)/.max(1)/g' | \
    # Remove any other clamp with low numbers
    sed 's/\.clamp(1, [0-9]\+)/.max(1)/g' | \
    # Disable memory check (change condition to false)
    sed 's/if max_threads\.is_some() || check_mem/if false/g' | \
    sed 's/if check_mem/if false/g' | \
    sed 's/if.*check_memory/if false/g' \
    > "$TEMP_FILE"

# Replace original file with modified version
mv "$TEMP_FILE" "$SETUP_FILE"

print_success "Code modified successfully!"

# Show what changed
echo ""
print_info "Changes made:"
if [ "$HAS_75_LIMIT" = true ]; then
    echo "  • Removed 75% CPU limit → now uses 100% of cores"
fi
if [ "$HAS_8_CAP" = true ]; then
    echo "  • Removed 8-thread cap → now unlimited threads"
fi
echo "  • Disabled memory checks → no automatic thread reduction"
echo ""

################################################################################
# STEP 7: BUILD THE MODIFIED VERSION
################################################################################

print_header "🔨 BUILDING OPTIMIZED VERSION"

cd ~/nexus-cli/$BUILD_DIR

print_info "This may take 5-10 minutes depending on your system..."
print_info "Building in release mode for maximum performance..."

# Clean previous builds
cargo clean > /dev/null 2>&1

# Build with release optimizations
if cargo build --release 2>&1 | tee /tmp/nexus_build.log; then
    print_success "Build completed successfully!"
else
    print_error "Build failed! Check /tmp/nexus_build.log for details"
    print_info "Restoring backup..."
    cp "$BACKUP_FILE" "$SETUP_FILE"
    exit 1
fi

################################################################################
# STEP 8: FIND & INSTALL THE NEW BINARY
################################################################################

print_header "📦 INSTALLING OPTIMIZED BINARY"

# Find the built binary
BUILT_BINARY=$(find target/release -name "$BINARY_NAME" -type f -executable | head -1)

if [ -z "$BUILT_BINARY" ]; then
    # Try alternative names
    BUILT_BINARY=$(find target/release -type f -executable | grep -E "nexus" | head -1)
fi

if [ -z "$BUILT_BINARY" ]; then
    print_error "Could not find built binary!"
    print_error "Expected: target/release/$BINARY_NAME"
    print_info "Available binaries:"
    ls -la target/release/ | grep -E "^-.*x"
    exit 1
fi

print_success "Found binary: $BUILT_BINARY"

# Find current installation location
INSTALL_LOCATION=""

if [ -f "$HOME/.nexus/bin/nexus-cli" ]; then
    INSTALL_LOCATION="$HOME/.nexus/bin/nexus-cli"
elif command -v nexus-cli &> /dev/null; then
    INSTALL_LOCATION=$(which nexus-cli)
else
    # Default location
    INSTALL_LOCATION="$HOME/.nexus/bin/nexus-cli"
    mkdir -p "$HOME/.nexus/bin"
fi

print_info "Installation location: $INSTALL_LOCATION"

# Backup existing binary
if [ -f "$INSTALL_LOCATION" ]; then
    BINARY_BACKUP="${INSTALL_LOCATION}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$INSTALL_LOCATION" "$BINARY_BACKUP"
    print_success "Backed up existing binary to: $BINARY_BACKUP"
fi

# Install new binary
cp "$BUILT_BINARY" "$INSTALL_LOCATION"
chmod +x "$INSTALL_LOCATION"

print_success "New binary installed successfully!"

################################################################################
# STEP 9: FINAL INSTRUCTIONS
################################################################################

print_header "✅ INSTALLATION COMPLETE!"

echo -e "${GREEN}Your Nexus CLI is now UNLEASHED!${NC}"
echo ""
print_info "What changed:"
echo "  • NO MORE thread limits - use ALL your CPU cores"
echo "  • NO MORE memory checks - manual control"
echo "  • Optimized build for maximum performance"
echo ""

print_header "🚀 HOW TO RUN"

echo "Start Nexus with maximum threads:"
echo -e "${CYAN}nexus-cli start --max-threads $TOTAL_CORES${NC}"
echo ""

echo "Recommended (based on your RAM):"
echo -e "${CYAN}nexus-cli start --max-threads $SAFE_THREADS${NC}"
echo ""

echo "Run in background with screen:"
echo -e "${CYAN}screen -S nexus${NC}"
echo -e "${CYAN}nexus-cli start --max-threads $SAFE_THREADS${NC}"
echo -e "${YELLOW}Press Ctrl+A then D to detach${NC}"
echo -e "${CYAN}screen -r nexus  # to reattach${NC}"
echo ""

print_header "⚠️ IMPORTANT WARNINGS"

print_warning "Each thread uses ~3-4GB RAM"
print_warning "Monitor your system temperature"
print_warning "Start with fewer threads and scale up"
echo ""

print_info "Your system can safely handle ~${SAFE_THREADS} threads"
echo ""

print_header "🔄 RESTORE ORIGINAL VERSION"

echo "If you want to go back to the original:"
echo -e "${CYAN}cp $BINARY_BACKUP $INSTALL_LOCATION${NC}"
echo ""
echo "Or reinstall fresh:"
echo -e "${CYAN}curl https://cli.nexus.xyz/ | sh${NC}"
echo ""

print_header "📊 QUICK TEST"

echo "Test if it's working:"
echo -e "${CYAN}nexus-cli start --max-threads 16${NC}"
echo ""
echo "If you see 'clamped to X threads' - something went wrong"
echo "If it starts with 16 threads - SUCCESS! 🎉"
echo ""

print_success "All done! Happy mining! 🚀"
print_info "Made by your coding assistant - share this script!"

################################################################################
# END OF SCRIPT
################################################################################
