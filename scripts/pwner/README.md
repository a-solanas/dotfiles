# Pwner - Debian Security VM Setup

Bootstrap scripts for setting up a Debian VM in UTM as a Kali replacement.

## Quick Start

### 1. Create VM in UTM
- Download Debian ISO
- Create new VM in UTM (Linux, Debian)
- Complete standard Debian installation

### 2. Configure Shared Folder
In UTM → VM Settings → Sharing:
- Add a shared directory pointing to this `pwner/` folder
- Name: `share`

### 3. Mount & Run
```bash
# Mount shared folder
sudo mkdir -p /mnt/share/pwner
sudo mount -t 9p -o trans=virtio share /mnt/share/pwner

# Fix DNS first
sudo /mnt/share/pwner/fix-dns.sh

# Run setup (first as root, then as pwner)
su -c /mnt/share/pwner/setup.sh
/mnt/share/pwner/setup.sh
```

## Scripts

| Script | Purpose |
|--------|---------|
| `fix-dns.sh` | Fix DNS (run with sudo first) |
| `setup.sh` | Install fish + base utilities |
| `modules/*.sh` | Optional tool categories |

## Adding Tools

Create module scripts in `modules/`:

```bash
# modules/recon.sh
sudo apt install -y nmap masscan
```

Then select them during bootstrap, or run directly:
```bash
source /mnt/share/pwner/modules/recon.sh
```
