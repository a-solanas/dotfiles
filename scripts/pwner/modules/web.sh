# Web fuzzing tools

# ffuf (from GitHub - not in Debian repos)
if ! command -v ffuf &>/dev/null; then
    print_info "Installing ffuf..."
    curl -L -o /tmp/ffuf.tar.gz https://github.com/ffuf/ffuf/releases/latest/download/ffuf_2.1.0_linux_arm64.tar.gz
    sudo tar -xz -C /usr/local/bin -f /tmp/ffuf.tar.gz ffuf
    rm -f /tmp/ffuf.tar.gz
fi

# feroxbuster
if ! command -v feroxbuster &>/dev/null; then
    print_info "Installing feroxbuster..."
    curl -L -o /tmp/feroxbuster-aarch64.zip https://github.com/epi052/feroxbuster/releases/latest/download/aarch64-linux-feroxbuster.zip
    sudo unzip -o /tmp/feroxbuster-aarch64.zip feroxbuster -d /usr/local/bin/
    sudo chmod +x /usr/local/bin/feroxbuster
    rm -f /tmp/feroxbuster-aarch64.zip
fi
