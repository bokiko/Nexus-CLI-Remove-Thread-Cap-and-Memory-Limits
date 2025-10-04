

# 🚀 Nexus CLI - Remove Thread Cap & Memory Limits Guide

## ⚡ Quick Guide to Unleash Full CPU Power on Nexus CLI

This guide removes the artificial thread limitations in Nexus CLI, allowing you to use all your CPU cores and RAM efficiently.

### 📋 Prerequisites
- Ubuntu/Linux machine
- Rust installed (guide includes installation)
- At least 16GB RAM recommended

### 🛠️ Step-by-Step Installation

#### 1️⃣ Clone the Repository
```bash
cd ~
git clone https://github.com/nexus-xyz/nexus-cli.git
cd ~/nexus-cli/clients/cli
```

#### 2️⃣ Install Rust (if not already installed)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
# Press 1 for default installation
source $HOME/.cargo/env
```

#### 3️⃣ Edit Thread Limitations
```bash
nano src/session/setup.rs
```

**Make these 3 critical changes:**

**Change #1 - Around Line 117 (Use 100% CPU instead of 75%):**
```rust
// BEFORE:
let max_workers = ((total_cores as f64 * 0.75).ceil() as usize).max(1);

// AFTER:
let max_workers = ((total_cores as f64 * 1.0).ceil() as usize).max(1);
```

**Change #2 - Around Line 118 (Remove thread clamping):**
```rust
// BEFORE:
let mut num_workers: usize = max_threads.unwrap_or(1).clamp(1, max_workers as u32) as usize;

// AFTER:
let mut num_workers: usize = max_threads.unwrap_or(1).max(1) as usize;
```

**Change #3 - Around Line 119 (Disable memory check):**
```rust
// BEFORE:
if max_threads.is_some() || check_mem {

// AFTER:
if false {  // Disabled memory check
```

Save and exit: `Ctrl+X`, then `Y`, then `Enter`

#### 4️⃣ Build the Modified Version
```bash
cargo build --release
# This will take 5-10 minutes
```

#### 5️⃣ Deploy the New Binary
```bash
# Backup existing binary (if exists)
cp ~/.nexus/bin/nexus-cli ~/.nexus/bin/nexus-cli.backup 2>/dev/null

# Install the modified binary
cp target/release/nexus-network ~/.nexus/bin/nexus-cli
chmod +x ~/.nexus/bin/nexus-cli
```

#### 6️⃣ Run with Maximum Threads
```bash
# Check your CPU cores
nproc

# Start in screen session
screen -S nexus
nexus-cli start --max-threads 32  # Adjust based on your CPU

# Detach from screen: Ctrl+A then D
```

### 📊 Verify It's Working
```bash
# Monitor CPU usage
htop
# Press F4 and search for "nexus"
```

### 🔧 What This Modification Does

| Limitation | Before | After |
|------------|--------|-------|
| CPU Usage | 75% max | 100% available |
| Thread Cap | 8-24 threads | Unlimited |
| Memory Check | 4GB per thread strict | Disabled |
| Max Workers | System dependent | User controlled |

### 💡 Tips for Different Systems

**For High-Core CPUs (32+ threads):**
```bash
nexus-cli start --max-threads 32
```

**For Systems with Limited RAM:**
```bash
# Use fewer threads if RAM is limited
# Formula: Available RAM ÷ 4GB = Max safe threads
nexus-cli start --max-threads 8  # For 32GB RAM
```

**For Running Multiple Instances:**
```bash
# Instance 1
screen -S nexus1
nexus-cli start --node-id YOUR_ID_1 --max-threads 16

# Instance 2 
screen -S nexus2
nexus-cli start --node-id YOUR_ID_2 --max-threads 16
```

### ⚠️ Important Notes

- Each thread uses approximately 3-4GB RAM
- Monitor system temperature when using all cores
- The memory check bypass assumes you have sufficient RAM
- Original binary is backed up as `nexus-cli.backup`

### 🔄 Restore Original Version
```bash
# If you need to revert
cp ~/.nexus/bin/nexus-cli.backup ~/.nexus/bin/nexus-cli

# Or reinstall official version
curl https://cli.nexus.xyz/ | sh
```

### 🐛 Troubleshooting

**Build fails with Rust error:**
```bash
rustup update
cargo clean
cargo build --release
```

**Binary not found:**
```bash
# Find your installation
which nexus-cli
# Binary location may vary
```

**Still getting memory warnings:**
```bash
# Ensure you changed line 119 to:
if false {  // This completely disables the check
```

### 📈 Performance Results

With these modifications on a Ryzen 7950X3D (32 threads, 64GB RAM):
- **Before:** Limited to 5-8 threads
- **After:** Full 32 threads utilized
- **Performance:** 4-6x increase in proof generation

### 🤝 Credits

Guide created for the Nexus community. Tested on Ubuntu 24.04 LTS with Nexus CLI v0.10.17.

---

*Last updated: October 2025*
*Tested with: Nexus CLI v0.10.17*

⭐ If this guide helped you, give it a star!
```

