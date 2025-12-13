<div align="center">

# Nexus CLI Unleash

<h3>Remove artificial thread caps and memory limits to unlock your CPU's full potential.</h3>

<p>
  <a href="https://quest.nexus.xyz/loyalty?referral_code=27YNOHL9"><img src="https://img.shields.io/badge/Join%20Nexus-Get%20Rewards-blue?style=for-the-badge" alt="Join Nexus" /></a>
</p>

<p>
  <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License" />
  <img src="https://img.shields.io/badge/bash-5.0+-green.svg" alt="Bash" />
  <img src="https://img.shields.io/badge/platform-Linux%20%7C%20Ubuntu-lightgrey.svg" alt="Platform" />
  <img src="https://img.shields.io/badge/status-active-success.svg" alt="Status" />
</p>

</div>

---

## What is This?

Nexus CLI artificially limits your CPU usage to **75%** (or 8 threads max in older versions). This script removes those limits safely, allowing you to use **100% of your CPU cores** for maximum mining performance.

> Join the Nexus project: [Click here](https://quest.nexus.xyz/loyalty?referral_code=27YNOHL9)

---

## Who is This For?

| User Type | Use Case |
|-----------|----------|
| **High-Core Miners** | Unlock all 16/32/64+ cores |
| **Server Operators** | Maximize datacenter hardware |
| **Nexus Network Participants** | Get maximum rewards from your hardware |
| **Performance Enthusiasts** | Remove artificial bottlenecks |

---

## Features

- ✅ **Fully Automated** - One command does everything
- ✅ **Version Detection** - Works with ALL Nexus CLI versions
- ✅ **Safe** - Creates backups before any changes
- ✅ **Smart** - Recommends optimal thread count based on RAM
- ✅ **Reversible** - Easy restore to original version
- ✅ **Error Handling** - Auto-restores on failure

---

## Performance Impact

| System | Before | After | Improvement |
|--------|--------|-------|-------------|
| **32 cores, 64GB RAM** | 24 threads (75% limit) | 32 threads | **+33%** |
| **32 cores, 128GB RAM** | 8 threads (hard cap) | 32 threads | **+300%** |
| **24 cores, 64GB RAM** | 8 threads (hard cap) | 16 threads | **+100%** |

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 LTS |
| **RAM** | 16 GB | 32 GB+ |
| **CPU** | 4+ cores | 16+ cores |
| **Storage** | 10 GB free | 20 GB+ free |

### RAM Guidelines

| RAM | Safe Thread Count |
|-----|-------------------|
| 16 GB | Up to 4 threads |
| 32 GB | Up to 8 threads |
| 64 GB | Up to 16 threads |
| 128 GB | Up to 32 threads |

> Each thread uses approximately **3-4 GB of RAM**

---

## Quick Start

### One-Line Installation

```bash
wget https://raw.githubusercontent.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits/main/nexus-unleash.sh && chmod +x nexus-unleash.sh && bash nexus-unleash.sh
```

**Or using curl:**

```bash
curl -O https://raw.githubusercontent.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits/main/nexus-unleash.sh && chmod +x nexus-unleash.sh && bash nexus-unleash.sh
```

---

# Technical Documentation

<details>
<summary><b>📥 Detailed Installation</b></summary>

### Step 1: Download the Script

**Option A: Using wget**
```bash
wget https://raw.githubusercontent.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits/main/nexus-unleash.sh
```

**Option B: Using curl**
```bash
curl -O https://raw.githubusercontent.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits/main/nexus-unleash.sh
```

**Option C: Clone the repository**
```bash
git clone https://github.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits.git
cd Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits
```

### Step 2: Make It Executable

```bash
chmod +x nexus-unleash.sh
```

### Step 3: Run the Script

```bash
bash nexus-unleash.sh
```

### Step 4: Follow the Prompts

The script will:
1. Display your system information (CPU cores, RAM)
2. Ask for confirmation to proceed
3. Install Rust if needed (automatic)
4. Clone/update Nexus CLI source
5. Detect your version automatically
6. Apply optimizations
7. Build the modified version (~5-10 minutes)
8. Install the new binary with backups

</details>

<details>
<summary><b>🎮 Usage Examples</b></summary>

### Basic Usage

**Start with maximum threads (all CPU cores):**
```bash
nexus-cli start --max-threads $(nproc)
```

**Start with specific thread count:**
```bash
nexus-cli start --max-threads 16
```

**Check your CPU core count:**
```bash
nproc
```

### Running in Background

**Using screen:**
```bash
screen -S nexus
nexus-cli start --max-threads 16
# Detach: Ctrl+A, then D
# Reattach: screen -r nexus
```

**Using tmux:**
```bash
tmux new -s nexus
nexus-cli start --max-threads 16
# Detach: Ctrl+B, then D
# Reattach: tmux attach -t nexus
```

### Monitoring

```bash
htop        # CPU usage
free -h     # Memory usage
sensors     # Temperatures
```

</details>

<details>
<summary><b>🔧 How It Works</b></summary>

The script modifies the Nexus CLI source code to remove artificial limitations:

### 1. CPU Limit Removal
```rust
// BEFORE: Only uses 75% of CPU cores
let max_workers = ((total_cores as f64 * 0.75).ceil() as usize).max(1);

// AFTER: Uses 100% of CPU cores
let max_workers = ((total_cores as f64 * 1.0).ceil() as usize).max(1);
```

### 2. Thread Cap Removal
```rust
// BEFORE: Maximum 8 threads regardless of cores
let num_workers = max_threads.unwrap_or(1).clamp(1, 8) as usize;

// AFTER: Unlimited threads
let num_workers = max_threads.unwrap_or(1).max(1) as usize;
```

### 3. Memory Check Bypass
```rust
// BEFORE: Automatically reduces threads on "low" memory
if max_threads.is_some() || check_mem {
    // memory checking code
}

// AFTER: Disabled (manual control)
if false {
    // never executes
}
```

### Version Detection

The script automatically detects your Nexus CLI version by:
1. Checking for new structure: `clients/cli/src/session/setup.rs`
2. Checking for old structure: `src/session/setup.rs`
3. Adapting modifications based on detected structure

</details>

<details>
<summary><b>🛡️ Safety & Backups</b></summary>

### Automatic Backups

**Source Code Backup:**
```
~/nexus-cli/[path]/setup.rs.backup.YYYYMMDD_HHMMSS
```

**Binary Backup:**
```
~/.nexus/bin/nexus-cli.backup.YYYYMMDD_HHMMSS
```

### Restoration Methods

**Method 1: Restore from Binary Backup**
```bash
ls -la ~/.nexus/bin/*.backup*
cp ~/.nexus/bin/nexus-cli.backup.20250104_143530 ~/.nexus/bin/nexus-cli
```

**Method 2: Fresh Installation**
```bash
curl https://cli.nexus.xyz/ | sh
```

**Method 3: Restore Source Code**
```bash
ls -la ~/nexus-cli/**/setup.rs.backup*
cp ~/nexus-cli/clients/cli/src/session/setup.rs.backup.* \
   ~/nexus-cli/clients/cli/src/session/setup.rs
cd ~/nexus-cli/clients/cli && cargo build --release
```

</details>

<details>
<summary><b>🔥 Troubleshooting</b></summary>

### "Rust not found"
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source $HOME/.cargo/env
```

### "Build failed"
```bash
rustup update
cd ~/nexus-cli/clients/cli
cargo clean
cargo build --release
```

### "Out of memory" when running
```bash
nexus-cli start --max-threads 4  # Start low, increase gradually
```

### "System freezing"
```bash
pkill nexus-cli
sensors  # Check temperature
nexus-cli start --max-threads 8  # Use fewer threads
```

### "Still seeing thread limit"
```bash
which nexus-cli  # Check location
bash nexus-unleash.sh  # Rebuild
```

</details>

<details>
<summary><b>❓ FAQ</b></summary>

**Q: Is this safe to use?**
A: Yes! Creates backups before changes. Always reversible.

**Q: Will this get me banned from Nexus?**
A: This only removes client-side limitations. No network protocols modified.

**Q: Does this work on Windows?**
A: No, Linux/Ubuntu only.

**Q: How much performance improvement?**
- 8+ cores limited to 8 threads: **+100% to +300%**
- Limited to 75%: **+33%**
- RAM-limited: Minimal (upgrade RAM first)

**Q: Do I need to rerun after Nexus updates?**
A: Yes, rerun the script after Nexus CLI updates.

**Q: What versions are supported?**
- v0.10.17+ (new structure with 75% limit)
- v0.10.0-16 (old structure with 8-thread cap)
- Earlier versions (detected automatically)

</details>

---

## Quick Commands

| Command | Description |
|---------|-------------|
| `nexus-cli start --max-threads $(nproc)` | Start with all cores |
| `nexus-cli start --max-threads 16` | Start with 16 threads |
| `nproc` | Check CPU core count |
| `htop` | Monitor CPU usage |
| `free -h` | Check RAM usage |

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## Roadmap

- [ ] Automated version checking
- [ ] Docker container deployment
- [ ] Monitoring dashboard integration
- [ ] Automatic thread scaling based on temperature
- [ ] Windows WSL support
- [ ] Web-based configuration tool

---

## Disclaimer

> ⚠️ **USE AT YOUR OWN RISK**
> - This script modifies Nexus CLI source code
> - High CPU usage increases electricity costs
> - Monitor system temperatures to prevent hardware damage
> - Not affiliated with or endorsed by Nexus
> - For educational and optimization purposes only

**Safety Practices:**
- ✅ Start with conservative thread counts
- ✅ Monitor system temperatures
- ✅ Ensure adequate cooling
- ✅ Keep backups of your data

---

## License

MIT License - See LICENSE file for details.

---

<div align="center">

Built by [@bokiko](https://github.com/bokiko)

*Unlock your CPU's full potential*

[![GitHub Stars](https://img.shields.io/github/stars/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits?style=social)](https://github.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits)
[![GitHub Forks](https://img.shields.io/github/forks/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits?style=social)](https://github.com/bokiko/Nexus-CLI-Remove-Thread-Cap-and-Memory-Limits/fork)

</div>
