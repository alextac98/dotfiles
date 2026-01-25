#!/bin/bash
# =============================================================================
# Dotfiles Bootstrap and Run Script
# =============================================================================
# Usage:
#   ./run.sh                  Run playbook for current host
#   ./run.sh --tags zsh       Run specific tags
#   ./run.sh --check --diff   Dry run
# =============================================================================

set -e

# =============================================================================
# Colors
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'  # No Color

# =============================================================================
# Helper Functions
# =============================================================================
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# =============================================================================
# Detect OS and Distro
# =============================================================================
detect_os() {
    case "$(uname -s)" in
        Darwin*)
            echo "darwin"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            error "Unsupported operating system: $(uname -s)"
            ;;
    esac
}

detect_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case "$ID" in
            ubuntu|debian|linuxmint|pop)
                echo "debian"
                ;;
            fedora|rhel|centos|rocky|almalinux)
                echo "redhat"
                ;;
            arch|manjaro|endeavouros)
                echo "arch"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

# =============================================================================
# Ensure Python 3 is Available
# =============================================================================
ensure_python() {
    local os="$1"
    
    if command -v python3 &> /dev/null; then
        return 0
    fi
    
    info "Python 3 not found. Installing..."
    
    if [[ "$os" == "darwin" ]]; then
        # macOS: Install via Homebrew
        if ! command -v brew &> /dev/null; then
            info "Installing Homebrew first..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
        fi
        brew install python3
    else
        local distro
        distro=$(detect_linux_distro)
        
        case "$distro" in
            debian)
                sudo apt-get update
                sudo apt-get install -y python3 python3-venv python3-pip
                ;;
            redhat)
                sudo dnf install -y python3 python3-pip
                ;;
            arch)
                sudo pacman -Sy --noconfirm python python-pip
                ;;
            *)
                error "Cannot install Python 3. Please install it manually."
                ;;
        esac
    fi
    
    if command -v python3 &> /dev/null; then
        success "Python 3 installed"
    else
        error "Python 3 installation failed"
    fi
}

# =============================================================================
# Setup Virtual Environment with Ansible
# =============================================================================
setup_venv() {
    local venv_dir="$1"
    
    if [[ -d "$venv_dir" ]] && [[ -x "$venv_dir/bin/ansible-playbook" ]]; then
        # Venv exists and has ansible
        return 0
    fi
    
    info "Setting up Python virtual environment..."
    
    # Create venv if it doesn't exist
    if [[ ! -d "$venv_dir" ]]; then
        python3 -m venv "$venv_dir"
    fi
    
    # Upgrade pip and install ansible
    info "Installing Ansible in virtual environment..."
    "$venv_dir/bin/pip" install --upgrade pip --quiet
    "$venv_dir/bin/pip" install ansible --quiet
    
    if [[ -x "$venv_dir/bin/ansible-playbook" ]]; then
        success "Ansible installed in virtual environment"
    else
        error "Failed to install Ansible"
    fi
}

# =============================================================================
# Check Hostname in Inventory
# =============================================================================
check_hostname_in_inventory() {
    local hostname="$1"
    local inventory="$2"
    
    # Check if hostname exists as a host entry (with optional trailing content)
    if grep -qE "^[[:space:]]+${hostname}:[[:space:]]*({})?[[:space:]]*$" "$inventory"; then
        return 0  # Found
    else
        return 1  # Not found
    fi
}

# =============================================================================
# Print Missing Host Error
# =============================================================================
print_missing_host_error() {
    local hostname="$1"
    local os_group="$2"
    
    echo ""
    echo -e "${RED}${BOLD}ERROR:${NC} Host '${BOLD}${hostname}${NC}' not found in inventory.yaml"
    echo ""
    echo -e "Add the following to ${BOLD}inventory.yaml${NC} under the '${BOLD}${os_group}${NC}' group:"
    echo ""
    echo -e "    ${os_group}:"
    echo -e "      hosts:"
    echo -e "        ${GREEN}${hostname}${NC}:"
    echo -e "          ansible_host: localhost"
    echo -e "          ansible_connection: local"
    echo ""
    echo -e "Then rerun: ${BOLD}./run.sh${NC}"
    echo ""
}

# =============================================================================
# Verify Script is Run from Repo Directory
# =============================================================================
verify_repo_directory() {
    local script_dir="$1"
    
    if [[ ! -f "${script_dir}/inventory.yaml" ]]; then
        error "inventory.yaml not found. Are you running from the dotfiles repository?"
    fi
    
    if [[ ! -f "${script_dir}/site.yaml" ]]; then
        error "site.yaml not found. Are you running from the dotfiles repository?"
    fi
    
    if [[ ! -d "${script_dir}/roles" ]]; then
        error "roles/ directory not found. Are you running from the dotfiles repository?"
    fi
}

# =============================================================================
# Main
# =============================================================================
main() {
    # Get the directory where this script lives
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    cd "$SCRIPT_DIR"
    
    # Venv location
    VENV_DIR="$SCRIPT_DIR/.venv"
    
    echo ""
    echo -e "${BOLD}Dotfiles${NC} - Ansible-based configuration management"
    echo "==========================================="
    echo ""
    
    # Verify we're in the right directory
    verify_repo_directory "$SCRIPT_DIR"
    
    # Detect OS
    OS=$(detect_os)
    # Use short hostname to match Ansible's ansible_facts.hostname
    CURRENT_HOSTNAME=$(hostname -s 2>/dev/null || hostname | cut -d. -f1)
    
    info "OS: $OS"
    info "Hostname: $CURRENT_HOSTNAME"
    echo ""
    
    # Ensure Python 3 is available
    ensure_python "$OS"
    
    # Setup virtual environment with Ansible
    setup_venv "$VENV_DIR"
    
    # Check hostname in inventory
    if ! check_hostname_in_inventory "$CURRENT_HOSTNAME" "inventory.yaml"; then
        print_missing_host_error "$CURRENT_HOSTNAME" "$OS"
        exit 1
    fi
    
    success "Host '$CURRENT_HOSTNAME' found in inventory"
    echo ""
    
    # Run playbook using venv's ansible-playbook
    info "Running Ansible playbook..."
    echo ""
    
    "$VENV_DIR/bin/ansible-playbook" site.yaml --limit "$CURRENT_HOSTNAME" "$@"
}

main "$@"
