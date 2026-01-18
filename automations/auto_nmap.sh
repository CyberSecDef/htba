#!/bin/bash

################################################################################
# Automated Nmap Enumeration Script v2.0
# Progressively scans targets and automatically runs service-specific scans
# Integrated tools: nmap, curl, dig, dnsenum, dnsrecon, enum4linux, finalrecon,
#                   ftp, gobuster, nikto, onesixtyone, ReconSpider, rpcclient,
#                   showmount, smbclient, smbmap, snmpwalk, wafw00f, wappalyzer,
#                   whatweb
#
# Features:
#   - Resume capability: specify existing output dir to skip completed steps
#   - Automatic credential discovery and re-use across services
#   - Service-specific deep enumeration
#   - Markdown report generation
#   - Virtual host and subdomain discovery
################################################################################

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR=""
CUSTOM_OUTPUT_DIR=""
LOG_FILE=""
COMMANDS_FILE=""
CREDENTIALS_FILE=""
DOMAINS_FILE=""
VHOSTS_FILE=""
HOSTS_ENTRIES_FILE=""
REPORT_FILE=""
SCAN_SUMMARY_FILE=""

# Wordlists
GOBUSTER_VHOST_WORDLIST="/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt"
GOBUSTER_DIR_WORDLIST="/usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt"
SNMP_COMMUNITY_LIST="/usr/share/seclists/Discovery/SNMP/snmp.txt"

# Tracking arrays for recursive enumeration
declare -A PROCESSED_DOMAINS
declare -A PROCESSED_HOSTS
declare -A DISCOVERED_CREDENTIALS
declare -A COMPLETED_SCANS
declare -A DISCOVERED_USERS
declare -A DISCOVERED_SHARES

# Resume tracking
RESUME_MODE=false

################################################################################
# Initialization Functions
################################################################################

init_output_dir() {
    if [[ -n "${CUSTOM_OUTPUT_DIR}" ]]; then
        OUTPUT_DIR="${CUSTOM_OUTPUT_DIR}"
        if [[ -d "${OUTPUT_DIR}" ]]; then
            RESUME_MODE=true
            log_message "${CYAN}[*] Resume mode: Using existing output directory${NC}"
        fi
    else
        OUTPUT_DIR="${SCRIPT_DIR}/nmap_scan_${TIMESTAMP}"
    fi
    
    # Set file paths
    LOG_FILE="${OUTPUT_DIR}/scan_log.txt"
    COMMANDS_FILE="${OUTPUT_DIR}/commands_executed.txt"
    CREDENTIALS_FILE="${OUTPUT_DIR}/discovered_credentials.txt"
    DOMAINS_FILE="${OUTPUT_DIR}/discovered_domains.txt"
    VHOSTS_FILE="${OUTPUT_DIR}/discovered_vhosts.txt"
    HOSTS_ENTRIES_FILE="${OUTPUT_DIR}/suggested_hosts_entries.txt"
    REPORT_FILE="${OUTPUT_DIR}/automation_report.md"
    SCAN_SUMMARY_FILE="${OUTPUT_DIR}/scan_summary.json"
    
    # Create output directory and subdirectories
    mkdir -p "${OUTPUT_DIR}"
    mkdir -p "${OUTPUT_DIR}/scans"
    mkdir -p "${OUTPUT_DIR}/logs"
    mkdir -p "${OUTPUT_DIR}/evidence"
    mkdir -p "${OUTPUT_DIR}/loot"
    
    touch "${CREDENTIALS_FILE}"
    touch "${DOMAINS_FILE}"
    touch "${VHOSTS_FILE}"
    touch "${HOSTS_ENTRIES_FILE}"
    
    # If resuming, pre-parse existing files
    if [[ "${RESUME_MODE}" == true ]]; then
        preparse_existing_output
    fi
}

preparse_existing_output() {
    log_message "${CYAN}[*] Pre-parsing existing output for resume capability...${NC}"
    
    # Parse completed nmap scans
    if [[ -d "${OUTPUT_DIR}/scans" ]]; then
        for xml_file in "${OUTPUT_DIR}/scans"/*.xml "${OUTPUT_DIR}"/*.xml; do
            if [[ -f "${xml_file}" ]]; then
                local scan_name=$(basename "${xml_file}" .xml)
                COMPLETED_SCANS["${scan_name}"]=1
                log_message "${GREEN}  [+] Found completed scan: ${scan_name}${NC}"
            fi
        done
    fi
    
    # Parse discovered credentials
    if [[ -f "${CREDENTIALS_FILE}" ]]; then
        while IFS= read -r line; do
            if [[ "${line}" =~ User:\ ([^\ ]+)\ Pass:\ ([^\ ]+) ]]; then
                local username="${BASH_REMATCH[1]}"
                local password="${BASH_REMATCH[2]}"
                local cred_key="auto:${username}:${password}"
                DISCOVERED_CREDENTIALS["${cred_key}"]=1
                log_message "${GREEN}  [+] Loaded credential: ${username}${NC}"
            fi
        done < "${CREDENTIALS_FILE}"
    fi
    
    # Parse discovered domains
    if [[ -f "${DOMAINS_FILE}" ]]; then
        while IFS= read -r domain; do
            if [[ -n "${domain}" ]]; then
                PROCESSED_DOMAINS["${domain}"]=1
                log_message "${GREEN}  [+] Loaded domain: ${domain}${NC}"
            fi
        done < "${DOMAINS_FILE}"
    fi
    
    # Parse discovered vhosts
    if [[ -f "${VHOSTS_FILE}" ]]; then
        while IFS= read -r vhost; do
            if [[ -n "${vhost}" ]]; then
                log_message "${GREEN}  [+] Loaded vhost: ${vhost}${NC}"
            fi
        done < "${VHOSTS_FILE}"
    fi
    
    # Count what was loaded
    local cred_count=${#DISCOVERED_CREDENTIALS[@]}
    local domain_count=${#PROCESSED_DOMAINS[@]}
    local scan_count=${#COMPLETED_SCANS[@]}
    
    log_message "${CYAN}[*] Resume summary: ${scan_count} scans, ${domain_count} domains, ${cred_count} credentials loaded${NC}"
}

is_scan_completed() {
    local scan_name="$1"
    [[ -n "${COMPLETED_SCANS[$scan_name]}" ]] || \
    [[ -f "${OUTPUT_DIR}/${scan_name}.xml" ]] || \
    [[ -f "${OUTPUT_DIR}/scans/${scan_name}.xml" ]]
}

mark_scan_completed() {
    local scan_name="$1"
    COMPLETED_SCANS["${scan_name}"]=1
}

################################################################################
# URL/Target Parsing Functions
################################################################################

parse_target() {
    local input="$1"
    local protocol=""
    local hostname=""
    local port=""
    local path=""
    
    # Check if input is a full URL (http:// or https://)
    if [[ "${input}" =~ ^(https?):// ]]; then
        protocol="${BASH_REMATCH[1]}"
        
        # Remove protocol
        local remainder="${input#*://}"
        
        # Extract hostname and port
        if [[ "${remainder}" =~ ^([^:/]+):([0-9]+)(.*) ]]; then
            # Format: protocol://hostname:port/path
            hostname="${BASH_REMATCH[1]}"
            port="${BASH_REMATCH[2]}"
            path="${BASH_REMATCH[3]}"
        elif [[ "${remainder}" =~ ^([^:/]+)(/.*)? ]]; then
            # Format: protocol://hostname/path (no explicit port)
            hostname="${BASH_REMATCH[1]}"
            path="${BASH_REMATCH[2]}"
            # Set default ports based on protocol
            if [[ "${protocol}" == "https" ]]; then
                port="443"
            else
                port="80"
            fi
        fi
    # Check if input is hostname:port format (no protocol)
    elif [[ "${input}" =~ ^([^:/]+):([0-9]+)$ ]]; then
        hostname="${BASH_REMATCH[1]}"
        port="${BASH_REMATCH[2]}"
        # Guess protocol based on common ports
        if [[ "${port}" == "443" ]] || [[ "${port}" == "8443" ]]; then
            protocol="https"
        else
            protocol="http"
        fi
    # Plain hostname or IP
    else
        hostname="${input}"
    fi
    
    # Output in format: protocol|hostname|port|path
    echo "${protocol}|${hostname}|${port}|${path}"
}

get_scan_target() {
    local parsed="$1"
    local hostname=$(echo "${parsed}" | cut -d'|' -f2)
    echo "${hostname}"
}

get_protocol() {
    local parsed="$1"
    echo "${parsed}" | cut -d'|' -f1
}

get_port() {
    local parsed="$1"
    echo "${parsed}" | cut -d'|' -f3
}

get_path() {
    local parsed="$1"
    echo "${parsed}" | cut -d'|' -f4
}

has_specific_port() {
    local parsed="$1"
    local port=$(get_port "${parsed}")
    [[ -n "${port}" ]]
}

has_protocol() {
    local parsed="$1"
    local protocol=$(get_protocol "${parsed}")
    [[ -n "${protocol}" ]]
}

log_message() {
    local message="$1"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${message}" | tee -a "${LOG_FILE}"
}

log_command() {
    local command="$1"
    echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] COMMAND: ${command}" >> "${COMMANDS_FILE}"
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] COMMAND: ${command}" >> "${LOG_FILE}"
}

check_tool() {
    local tool="$1"
    if ! command -v "${tool}" &> /dev/null; then
        log_message "${YELLOW}[!] Warning: ${tool} not found, skipping ${tool} scans${NC}"
        return 1
    fi
    return 0
}

add_discovered_domain() {
    local domain="$1"
    if [[ -z "${PROCESSED_DOMAINS[$domain]}" ]]; then
        PROCESSED_DOMAINS[$domain]=1
        echo "${domain}" >> "${DOMAINS_FILE}"
        log_message "${CYAN}[+] New domain discovered: ${domain}${NC}"
        return 0
    fi
    return 1
}

add_discovered_credential() {
    local cred_type="$1"
    local username="$2"
    local password="$3"
    local source="$4"
    
    local cred_key="${cred_type}:${username}:${password}"
    if [[ -z "${DISCOVERED_CREDENTIALS[$cred_key]}" ]]; then
        DISCOVERED_CREDENTIALS[$cred_key]=1
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] ${cred_type} - User: ${username} Pass: ${password} (Source: ${source})" >> "${CREDENTIALS_FILE}"
        log_message "${MAGENTA}[!] CREDENTIAL FOUND: ${cred_type} ${username}:${password} from ${source}${NC}"
        return 0
    fi
    return 1
}

add_vhost() {
    local vhost="$1"
    local ip="$2"
    
    echo "${vhost}" >> "${VHOSTS_FILE}"
    echo "${ip}    ${vhost}" >> "${HOSTS_ENTRIES_FILE}"
    log_message "${CYAN}[+] Virtual host discovered: ${vhost} -> ${ip}${NC}"
}

add_discovered_user() {
    local username="$1"
    local source="$2"
    
    if [[ -z "${DISCOVERED_USERS[$username]}" ]]; then
        DISCOVERED_USERS[$username]="${source}"
        log_message "${CYAN}[+] User discovered: ${username} (from ${source})${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] User: ${username} (Source: ${source})" >> "${OUTPUT_DIR}/discovered_users.txt"
        return 0
    fi
    return 1
}

add_discovered_share() {
    local share="$1"
    local permissions="$2"
    local source="$3"
    
    local share_key="${share}:${permissions}"
    if [[ -z "${DISCOVERED_SHARES[$share_key]}" ]]; then
        DISCOVERED_SHARES[$share_key]="${source}"
        log_message "${CYAN}[+] Share discovered: ${share} [${permissions}]${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Share: ${share} Permissions: ${permissions} (Source: ${source})" >> "${OUTPUT_DIR}/discovered_shares.txt"
        return 0
    fi
    return 1
}

run_nmap() {
    local scan_name="$1"
    local target="$2"
    shift 2
    local nmap_args="$@"
    
    local output_file="${OUTPUT_DIR}/scans/${target//\//_}_${scan_name}"
    
    # Check if scan already completed (resume mode)
    if is_scan_completed "${target//\//_}_${scan_name}"; then
        log_message "${YELLOW}[*] Skipping completed scan: ${scan_name}${NC}"
        echo "${output_file}.xml"
        return
    fi
    
    local full_command="nmap ${nmap_args} -oA \"${output_file}\" ${target}"
    
    log_message "${BLUE}Running: ${scan_name}${NC}"
    log_command "${full_command}"
    
    eval "${full_command}" 2>&1 | tee -a "${LOG_FILE}"
    
    mark_scan_completed "${target//\//_}_${scan_name}"
    
    echo "${output_file}.xml"
}

run_tool() {
    local tool_name="$1"
    local output_file="$2"
    shift 2
    local command="$@"
    
    # Check if output already exists (resume mode)
    if [[ "${RESUME_MODE}" == true ]] && [[ -f "${output_file}" ]] && [[ -s "${output_file}" ]]; then
        log_message "${YELLOW}[*] Skipping (output exists): ${tool_name}${NC}"
        echo "${output_file}"
        return
    fi
    
    log_message "${BLUE}Running: ${tool_name}${NC}"
    log_command "${command}"
    
    eval "${command}" > "${output_file}" 2>&1
    cat "${output_file}" >> "${LOG_FILE}"
    
    echo "${output_file}"
}

parse_open_ports() {
    local xml_file="$1"
    if [[ -f "${xml_file}" ]]; then
        grep -oP 'portid="\K[0-9]+' "${xml_file}" | sort -u
    fi
}

parse_services() {
    local xml_file="$1"
    if [[ -f "${xml_file}" ]]; then
        grep -oP 'service name="\K[^"]+' "${xml_file}" | sort -u
    fi
}

check_port_service() {
    local xml_file="$1"
    local port="$2"
    if [[ -f "${xml_file}" ]]; then
        grep "portid=\"${port}\"" "${xml_file}" | grep -oP 'service name="\K[^"]+'
    fi
}

extract_ip_from_target() {
    local target="$1"
    # If it's already an IP, return it
    if [[ "${target}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "${target}"
    else
        # Try to resolve domain to IP
        dig +short "${target}" | head -n1
    fi
}

################################################################################
# DNS Enumeration Functions
################################################################################

enumerate_dns_full() {
    local domain="$1"
    
    # Check if already processed
    if [[ -n "${PROCESSED_DOMAINS[$domain]}" ]]; then
        return
    fi
    
    log_message "${GREEN}[*] Full DNS enumeration for: ${domain}${NC}"
    PROCESSED_DOMAINS[$domain]=1
    
    # dig enumeration
    enumerate_with_dig "${domain}"
    
    # dnsenum
    if check_tool "dnsenum"; then
        enumerate_with_dnsenum "${domain}"
    fi
    
    # dnsrecon
    if check_tool "dnsrecon"; then
        enumerate_with_dnsrecon "${domain}"
    fi
}

enumerate_with_dig() {
    local domain="$1"
    local output_base="${OUTPUT_DIR}/${domain}_dig"
    
    if ! check_tool "dig"; then
        return
    fi
    
    log_message "${GREEN}[*] Running dig enumeration on ${domain}${NC}"
    
    # Standard record types
    local record_types=("A" "AAAA" "MX" "NS" "TXT" "SOA" "CNAME" "PTR" "SRV")
    
    for record in "${record_types[@]}"; do
        local output_file="${output_base}_${record}.txt"
        run_tool "dig ${record}" "${output_file}" "dig ${domain} ${record} +noall +answer"
        
        # Extract any new domains from results
        if [[ -f "${output_file}" ]]; then
            grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${output_file}" | \
            while read -r new_domain; do
                if add_discovered_domain "${new_domain}"; then
                    enumerate_dns_full "${new_domain}"
                fi
            done
        fi
    done
    
    # Attempt zone transfer on discovered nameservers
    local ns_file="${output_base}_NS.txt"
    if [[ -f "${ns_file}" ]]; then
        grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${ns_file}" | \
        while read -r nameserver; do
            local axfr_output="${output_base}_AXFR_${nameserver}.txt"
            log_message "${YELLOW}[*] Attempting zone transfer from ${nameserver}${NC}"
            run_tool "dig AXFR" "${axfr_output}" "dig @${nameserver} ${domain} AXFR"
            
            # Extract domains from successful zone transfer
            if [[ -f "${axfr_output}" ]] && ! grep -q "Transfer failed" "${axfr_output}"; then
                grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${axfr_output}" | \
                while read -r new_domain; do
                    if add_discovered_domain "${new_domain}"; then
                        enumerate_dns_full "${new_domain}"
                    fi
                done
            fi
        done
    fi
    
    # Reverse DNS lookup
    local a_file="${output_base}_A.txt"
    if [[ -f "${a_file}" ]]; then
        grep -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' "${a_file}" | \
        while read -r ip; do
            local ptr_output="${output_base}_PTR_${ip}.txt"
            run_tool "dig PTR" "${ptr_output}" "dig -x ${ip} +short"
        done
    fi
}

enumerate_with_dnsenum() {
    local domain="$1"
    local output_file="${OUTPUT_DIR}/${domain}_dnsenum.txt"
    
    log_message "${GREEN}[*] Running dnsenum on ${domain}${NC}"
    
    run_tool "dnsenum" "${output_file}" "dnsenum --enum ${domain}"
    
    # Parse results for new domains/subdomains
    if [[ -f "${output_file}" ]]; then
        grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${output_file}" | \
        sort -u | \
        while read -r new_domain; do
            if add_discovered_domain "${new_domain}"; then
                enumerate_dns_full "${new_domain}"
            fi
        done
    fi
}

enumerate_with_dnsrecon() {
    local domain="$1"
    local output_file="${OUTPUT_DIR}/${domain}_dnsrecon.txt"
    
    log_message "${GREEN}[*] Running dnsrecon on ${domain}${NC}"
    
    # Standard enumeration
    run_tool "dnsrecon std" "${output_file}" "dnsrecon -d ${domain} -t std"
    
    # Zone transfer attempt
    local axfr_output="${OUTPUT_DIR}/${domain}_dnsrecon_axfr.txt"
    run_tool "dnsrecon axfr" "${axfr_output}" "dnsrecon -d ${domain} -t axfr"
    
    # Brute force subdomains
    local brute_output="${OUTPUT_DIR}/${domain}_dnsrecon_brute.txt"
    run_tool "dnsrecon brute" "${brute_output}" "dnsrecon -d ${domain} -t brt"
    
    # Parse all results for new domains
    for file in "${output_file}" "${axfr_output}" "${brute_output}"; do
        if [[ -f "${file}" ]]; then
            grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${file}" | \
            sort -u | \
            while read -r new_domain; do
                if add_discovered_domain "${new_domain}"; then
                    enumerate_dns_full "${new_domain}"
                fi
            done
        fi
    done
}

################################################################################
# Web Enumeration Functions
################################################################################

enumerate_web_full() {
    local target="$1"
    local port="$2"
    local protocol="$3"  # http or https
    
    local url="${protocol}://${target}:${port}"
    local safe_name="${target//\//_}_${port}"
    
    log_message "${GREEN}[*] Full web enumeration for: ${url}${NC}"
    
    # curl enumeration
    enumerate_with_curl "${url}" "${safe_name}"
    
    # finalrecon
    if check_tool "finalrecon"; then
        enumerate_with_finalrecon "${url}" "${safe_name}"
    fi
    
    # gobuster vhost discovery
    if check_tool "gobuster" && [[ -f "${GOBUSTER_VHOST_WORDLIST}" ]]; then
        enumerate_with_gobuster_vhost "${target}" "${port}" "${safe_name}"
    fi
    
    # nikto
    if check_tool "nikto"; then
        enumerate_with_nikto "${url}" "${safe_name}"
    fi
    
    # ReconSpider
    if [[ -f "${HOME}/.local/bin/ReconSpider.py" ]]; then
        enumerate_with_reconspider "${url}" "${safe_name}"
    fi
    
    # wafw00f
    if check_tool "wafw00f"; then
        enumerate_with_wafw00f "${url}" "${safe_name}"
    fi
    
    # wappalyzer (CLI)
    if check_tool "wappalyzer"; then
        enumerate_with_wappalyzer "${url}" "${safe_name}"
    fi
    
    # whatweb
    if check_tool "whatweb"; then
        enumerate_with_whatweb "${url}" "${safe_name}"
    fi
}

enumerate_with_curl() {
    local url="$1"
    local safe_name="$2"
    local output_base="${OUTPUT_DIR}/${safe_name}_curl"
    
    log_message "${GREEN}[*] Running curl enumeration on ${url}${NC}"
    
    # Headers
    run_tool "curl headers" "${output_base}_headers.txt" "curl -I -L -s \"${url}\""
    
    # Full HTML source
    run_tool "curl source" "${output_base}_source.html" "curl -L -s \"${url}\""
    
    # robots.txt
    run_tool "curl robots" "${output_base}_robots.txt" "curl -s \"${url}/robots.txt\""
    
    # sitemap.xml
    run_tool "curl sitemap" "${output_base}_sitemap.xml" "curl -s \"${url}/sitemap.xml\""
    
    # Common files
    local common_files=("security.txt" ".well-known/security.txt" "README.md" ".git/config" ".env" "composer.json" "package.json")
    for file in "${common_files[@]}"; do
        local file_safe="${file//\//_}"
        run_tool "curl ${file}" "${output_base}_${file_safe}.txt" "curl -s \"${url}/${file}\""
    done
    
    # Test HTTP methods
    run_tool "curl options" "${output_base}_options.txt" "curl -X OPTIONS -i -s \"${url}\""
    
    # Extract domains from HTML source
    if [[ -f "${output_base}_source.html" ]]; then
        grep -oE 'https?://([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${output_base}_source.html" | \
        sed 's|https\?://||' | \
        cut -d'/' -f1 | \
        sort -u | \
        while read -r domain; do
            if add_discovered_domain "${domain}"; then
                enumerate_dns_full "${domain}"
            fi
        done
    fi
}

enumerate_with_finalrecon() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_finalrecon.txt"
    
    log_message "${GREEN}[*] Running finalrecon on ${url}${NC}"
    
    # Extract domain from URL
    local domain=$(echo "${url}" | sed -E 's|https?://||' | cut -d':' -f1 | cut -d'/' -f1)
    
    run_tool "finalrecon" "${output_file}" "finalrecon --url ${url} --full"
}

enumerate_with_gobuster_dir() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_gobuster_dir.txt"
    
    if ! check_tool "gobuster"; then
        return
    fi
    
    if [[ ! -f "${GOBUSTER_DIR_WORDLIST}" ]]; then
        log_message "${YELLOW}[!] Directory wordlist not found: ${GOBUSTER_DIR_WORDLIST}${NC}"
        return
    fi
    
    log_message "${GREEN}[*] Running gobuster directory scan on ${url}${NC}"
    
    run_tool "gobuster dir" "${output_file}" \
        "gobuster dir -u \"${url}\" -w ${GOBUSTER_DIR_WORDLIST} -t 50 -q -e -x php,html,txt,asp,aspx,jsp"
    
    # Parse discovered directories
    if [[ -f "${output_file}" ]]; then
        grep -E "Status: (200|301|302|403)" "${output_file}" | \
        while read -r line; do
            log_message "${CYAN}  [+] Directory found: ${line}${NC}"
        done
    fi
}

enumerate_with_gobuster_vhost() {
    local target="$1"
    local port="$2"
    local safe_name="$3"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_gobuster_vhost.txt"
    
    log_message "${GREEN}[*] Running gobuster vhost discovery on ${target}${NC}"
    
    run_tool "gobuster vhost" "${output_file}" \
        "gobuster vhost -u http://${target}:${port} -w ${GOBUSTER_VHOST_WORDLIST} --append-domain -t 50"
    
    # Parse discovered vhosts
    if [[ -f "${output_file}" ]]; then
        grep "Found:" "${output_file}" | grep -oE '([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' | \
        while read -r vhost; do
            local target_ip=$(extract_ip_from_target "${target}")
            add_vhost "${vhost}" "${target_ip}"
            
            # Trigger full enumeration on discovered vhost
            if add_discovered_domain "${vhost}"; then
                enumerate_dns_full "${vhost}"
            fi
        done
        
        # Display reminder if vhosts found
        if grep -q "Found:" "${output_file}"; then
            log_message "${YELLOW}╔═══════════════════════════════════════════════════════════════════╗${NC}"
            log_message "${YELLOW}║  REMINDER: Virtual hosts discovered!                             ║${NC}"
            log_message "${YELLOW}║  Update /etc/hosts with entries from:                            ║${NC}"
            log_message "${YELLOW}║  ${HOSTS_ENTRIES_FILE}${NC}"
            log_message "${YELLOW}╚═══════════════════════════════════════════════════════════════════╝${NC}"
        fi
    fi
}

enumerate_with_nikto() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/${safe_name}_nikto.txt"
    
    log_message "${GREEN}[*] Running nikto on ${url}${NC}"
    
    run_tool "nikto" "${output_file}" "nikto -h \"${url}\" -C all"
}

enumerate_with_reconspider() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/${safe_name}_reconspider.txt"
    
    log_message "${GREEN}[*] Running ReconSpider on ${url}${NC}"
    
    run_tool "ReconSpider" "${output_file}" "python3 ~/.local/bin/ReconSpider.py ${url}"
    
    # Parse for new domains/URLs
    if [[ -f "${output_file}" ]]; then
        grep -oE 'https?://([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}' "${output_file}" | \
        sed 's|https\?://||' | \
        cut -d'/' -f1 | \
        sort -u | \
        while read -r domain; do
            if add_discovered_domain "${domain}"; then
                enumerate_dns_full "${domain}"
            fi
        done
    fi
}

enumerate_with_wafw00f() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/${safe_name}_wafw00f.txt"
    
    log_message "${GREEN}[*] Running wafw00f on ${url}${NC}"
    
    run_tool "wafw00f" "${output_file}" "wafw00f \"${url}\""
}

enumerate_with_wappalyzer() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/${safe_name}_wappalyzer.txt"
    
    log_message "${GREEN}[*] Running wappalyzer on ${url}${NC}"
    
    run_tool "wappalyzer" "${output_file}" "wappalyzer \"${url}\""
}

enumerate_with_whatweb() {
    local url="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_whatweb.txt"
    
    log_message "${GREEN}[*] Running whatweb on ${url}${NC}"
    
    run_tool "whatweb" "${output_file}" "whatweb -a 3 -v \"${url}\""
}

################################################################################
# SMB/RPC Enumeration Functions
################################################################################

enumerate_smb_full() {
    local target="$1"
    
    log_message "${GREEN}[*] Full SMB enumeration on ${target}${NC}"
    
    local safe_name="${target//\//_}"
    
    # enum4linux comprehensive scan
    if check_tool "enum4linux"; then
        enumerate_with_enum4linux "${target}" "${safe_name}"
    fi
    
    # smbmap anonymous scan
    if check_tool "smbmap"; then
        enumerate_with_smbmap "${target}" "${safe_name}"
    fi
    
    # smbclient share listing
    if check_tool "smbclient"; then
        enumerate_with_smbclient "${target}" "${safe_name}"
    fi
    
    # Try with discovered credentials
    for cred_key in "${!DISCOVERED_CREDENTIALS[@]}"; do
        IFS=':' read -r cred_type username password <<< "${cred_key}"
        if [[ -n "${username}" ]] && [[ -n "${password}" ]]; then
            enumerate_smb_authenticated "${target}" "${safe_name}" "${username}" "${password}"
        fi
    done
}

enumerate_with_enum4linux() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_enum4linux.txt"
    
    log_message "${GREEN}[*] Running enum4linux on ${target}${NC}"
    
    run_tool "enum4linux" "${output_file}" "enum4linux -a ${target}"
    
    # Parse results for users
    if [[ -f "${output_file}" ]]; then
        grep -oE "user:\[([^\]]+)\]" "${output_file}" | sed 's/user:\[\(.*\)\]/\1/' | \
        while read -r user; do
            add_discovered_user "${user}" "enum4linux"
        done
        
        # Parse for shares
        grep -E "^\s+[A-Za-z]+\s+Disk" "${output_file}" | awk '{print $1}' | \
        while read -r share; do
            add_discovered_share "${share}" "unknown" "enum4linux"
        done
    fi
}

enumerate_with_smbmap() {
    local target="$1"
    local safe_name="$2"
    local output_base="${OUTPUT_DIR}/logs/${safe_name}_smbmap"
    
    log_message "${GREEN}[*] Running smbmap on ${target}${NC}"
    
    # Anonymous access
    run_tool "smbmap anon" "${output_base}_anon.txt" "smbmap -H ${target}"
    
    # Null session
    run_tool "smbmap null" "${output_base}_null.txt" "smbmap -H ${target} -u '' -p ''"
    
    # Guest session
    run_tool "smbmap guest" "${output_base}_guest.txt" "smbmap -H ${target} -u 'guest' -p ''"
    
    # Parse results for shares
    for file in "${output_base}"*.txt; do
        if [[ -f "${file}" ]]; then
            grep -E "^\s+\w+\s+(READ|WRITE|NO ACCESS)" "${file}" | \
            while read -r line; do
                local share=$(echo "${line}" | awk '{print $1}')
                local perm=$(echo "${line}" | awk '{print $2}')
                add_discovered_share "${share}" "${perm}" "smbmap"
            done
        fi
    done
}

enumerate_with_smbclient() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_smbclient.txt"
    
    log_message "${GREEN}[*] Running smbclient share listing on ${target}${NC}"
    
    run_tool "smbclient list" "${output_file}" "smbclient -L //${target} -N"
    
    # Parse share names
    if [[ -f "${output_file}" ]]; then
        grep -E "^\s+\S+\s+Disk" "${output_file}" | awk '{print $1}' | \
        while read -r share; do
            add_discovered_share "${share}" "unknown" "smbclient"
        done
    fi
}

enumerate_smb_authenticated() {
    local target="$1"
    local safe_name="$2"
    local username="$3"
    local password="$4"
    local output_base="${OUTPUT_DIR}/logs/${safe_name}_smb_auth_${username}"
    
    log_message "${YELLOW}[*] Trying authenticated SMB enumeration with ${username}${NC}"
    
    # smbmap with creds
    if check_tool "smbmap"; then
        run_tool "smbmap auth" "${output_base}_smbmap.txt" \
            "smbmap -H ${target} -u '${username}' -p '${password}'"
        
        # If we have access, try to recursively list
        run_tool "smbmap recursive" "${output_base}_smbmap_recursive.txt" \
            "smbmap -H ${target} -u '${username}' -p '${password}' -r"
    fi
    
    # smbclient with creds - list shares
    if check_tool "smbclient"; then
        run_tool "smbclient auth" "${output_base}_smbclient.txt" \
            "smbclient -L //${target} -U '${username}%${password}'"
    fi
}

enumerate_rpc() {
    local target="$1"
    local port="$2"
    
    if ! check_tool "rpcclient"; then
        return
    fi
    
    log_message "${GREEN}[*] Enumerating RPC on ${target}:${port}${NC}"
    
    local safe_name="${target//\//_}_rpc_${port}"
    
    # Try anonymous/null session first
    enumerate_rpcclient_anonymous "${target}" "${safe_name}"
    
    # Try with discovered credentials
    if [[ -f "${CREDENTIALS_FILE}" ]]; then
        while IFS= read -r cred_line; do
            if [[ "${cred_line}" =~ User:\ ([^\ ]+)\ Pass:\ ([^\ ]+) ]]; then
                local username="${BASH_REMATCH[1]}"
                local password="${BASH_REMATCH[2]}"
                enumerate_rpcclient_auth "${target}" "${safe_name}" "${username}" "${password}"
            fi
        done < "${CREDENTIALS_FILE}"
    fi
}

enumerate_rpcclient_anonymous() {
    local target="$1"
    local safe_name="$2"
    local output_base="${OUTPUT_DIR}/logs/${safe_name}_anonymous"
    
    log_message "${YELLOW}[*] Trying rpcclient with null session${NC}"
    
    # Null session
    echo "" | run_tool "rpcclient null" "${output_base}_null.txt" \
        "rpcclient -U '' -N ${target} -c 'enumdomains; enumdomusers; enumdomgroups; querydominfo'"
    
    # Guest session
    run_tool "rpcclient guest" "${output_base}_guest.txt" \
        "rpcclient -U 'guest%' ${target} -c 'enumdomains; enumdomusers; enumdomgroups; querydominfo; lsaenumsid'"
    
    # Parse for credentials/users
    for file in "${output_base}"*.txt; do
        if [[ -f "${file}" ]]; then
            # Look for user information
            grep -oE "user:\[.*\]" "${file}" >> "${LOG_FILE}"
        fi
    done
}

enumerate_rpcclient_auth() {
    local target="$1"
    local safe_name="$2"
    local username="$3"
    local password="$4"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_auth_${username}.txt"
    
    log_message "${YELLOW}[*] Trying rpcclient with credentials: ${username}${NC}"
    
    run_tool "rpcclient auth" "${output_file}" \
        "rpcclient -U '${username}%${password}' ${target} -c 'enumdomains; enumdomusers; enumdomgroups; querydominfo; lsaenumsid; getdompwinfo; querydispinfo'"
}

################################################################################
# FTP Enumeration Functions
################################################################################

enumerate_ftp_full() {
    local target="$1"
    local port="$2"
    
    log_message "${GREEN}[*] Full FTP enumeration on ${target}:${port}${NC}"
    
    local safe_name="${target//\//_}_ftp_${port}"
    
    # Try anonymous FTP access
    enumerate_ftp_anonymous "${target}" "${port}" "${safe_name}"
    
    # Try with discovered credentials
    for cred_key in "${!DISCOVERED_CREDENTIALS[@]}"; do
        IFS=':' read -r cred_type username password <<< "${cred_key}"
        if [[ -n "${username}" ]] && [[ -n "${password}" ]]; then
            enumerate_ftp_authenticated "${target}" "${port}" "${safe_name}" "${username}" "${password}"
        fi
    done
}

enumerate_ftp_anonymous() {
    local target="$1"
    local port="$2"
    local safe_name="$3"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_anonymous.txt"
    
    if ! check_tool "ftp"; then
        return
    fi
    
    log_message "${YELLOW}[*] Trying anonymous FTP access on ${target}:${port}${NC}"
    
    # Try anonymous login and list
    run_tool "ftp anonymous" "${output_file}" \
        "timeout 30 ftp -n ${target} ${port} <<EOF
user anonymous anonymous@
pwd
ls -la
quit
EOF"
    
    # Check if anonymous access worked
    if [[ -f "${output_file}" ]] && ! grep -qE "Login failed|Access denied|Permission denied" "${output_file}"; then
        if grep -qE "drwx|^-rw" "${output_file}"; then
            log_message "${MAGENTA}[!] Anonymous FTP access SUCCESSFUL on ${target}:${port}${NC}"
            add_discovered_credential "FTP" "anonymous" "anonymous@" "anonymous_ftp"
        fi
    fi
}

enumerate_ftp_authenticated() {
    local target="$1"
    local port="$2"
    local safe_name="$3"
    local username="$4"
    local password="$5"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_auth_${username}.txt"
    
    log_message "${YELLOW}[*] Trying FTP with credentials: ${username}${NC}"
    
    run_tool "ftp auth ${username}" "${output_file}" \
        "timeout 30 ftp -n ${target} ${port} <<EOF
user ${username} ${password}
pwd
ls -la
quit
EOF"
    
    # Check for success and interesting files
    if [[ -f "${output_file}" ]] && grep -qE "drwx|^-rw" "${output_file}"; then
        log_message "${MAGENTA}[!] FTP access with ${username} SUCCESSFUL${NC}"
        
        # Look for interesting files
        grep -E "\.(txt|conf|xml|bak|sql|key|pem|crt)$" "${output_file}" >> "${OUTPUT_DIR}/loot/interesting_ftp_files.txt"
    fi
}

################################################################################
# NFS Enumeration Functions
################################################################################

enumerate_nfs_full() {
    local target="$1"
    
    log_message "${GREEN}[*] Full NFS enumeration on ${target}${NC}"
    
    local safe_name="${target//\//_}"
    
    # showmount
    if check_tool "showmount"; then
        enumerate_with_showmount "${target}" "${safe_name}"
    fi
    
    # rpcinfo
    if check_tool "rpcinfo"; then
        enumerate_with_rpcinfo "${target}" "${safe_name}"
    fi
}

enumerate_with_showmount() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_showmount.txt"
    
    log_message "${GREEN}[*] Running showmount on ${target}${NC}"
    
    run_tool "showmount" "${output_file}" "showmount -e ${target}"
    
    # Parse exports
    if [[ -f "${output_file}" ]]; then
        grep "^/" "${output_file}" | while read -r export; do
            log_message "${CYAN}  [+] NFS Export found: ${export}${NC}"
            echo "${export}" >> "${OUTPUT_DIR}/discovered_nfs_exports.txt"
        done
    fi
}

enumerate_with_rpcinfo() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_rpcinfo.txt"
    
    log_message "${GREEN}[*] Running rpcinfo on ${target}${NC}"
    
    run_tool "rpcinfo" "${output_file}" "rpcinfo -p ${target}"
}

################################################################################
# SNMP Enumeration Functions
################################################################################

enumerate_snmp_full() {
    local target="$1"
    local port="$2"
    
    log_message "${GREEN}[*] Full SNMP enumeration on ${target}:${port}${NC}"
    
    local safe_name="${target//\//_}_snmp"
    
    # onesixtyone community string discovery
    if check_tool "onesixtyone" && [[ -f "${SNMP_COMMUNITY_LIST}" ]]; then
        enumerate_with_onesixtyone "${target}" "${safe_name}"
    fi
    
    # snmpwalk with common community strings
    if check_tool "snmpwalk"; then
        enumerate_with_snmpwalk "${target}" "${safe_name}"
    fi
    
    # snmp-check
    if check_tool "snmp-check"; then
        enumerate_with_snmpcheck "${target}" "${safe_name}"
    fi
}

enumerate_with_onesixtyone() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_onesixtyone.txt"
    
    log_message "${GREEN}[*] Running onesixtyone community string discovery on ${target}${NC}"
    
    run_tool "onesixtyone" "${output_file}" "onesixtyone -c ${SNMP_COMMUNITY_LIST} ${target}"
    
    # Parse discovered community strings
    if [[ -f "${output_file}" ]]; then
        grep -oE "\[.*\]" "${output_file}" | tr -d '[]' | \
        while read -r community; do
            if [[ -n "${community}" ]]; then
                log_message "${MAGENTA}[!] SNMP community string found: ${community}${NC}"
                echo "${community}" >> "${OUTPUT_DIR}/discovered_snmp_communities.txt"
            fi
        done
    fi
}

enumerate_with_snmpwalk() {
    local target="$1"
    local safe_name="$2"
    
    # Common community strings to try
    local communities=("public" "private" "manager")
    
    # Also use any discovered community strings
    if [[ -f "${OUTPUT_DIR}/discovered_snmp_communities.txt" ]]; then
        while read -r community; do
            communities+=("${community}")
        done < "${OUTPUT_DIR}/discovered_snmp_communities.txt"
    fi
    
    for community in "${communities[@]}"; do
        local output_file="${OUTPUT_DIR}/logs/${safe_name}_snmpwalk_${community}.txt"
        
        log_message "${GREEN}[*] Running snmpwalk with community '${community}'${NC}"
        
        run_tool "snmpwalk ${community}" "${output_file}" \
            "snmpwalk -v2c -c ${community} ${target} 2>&1 | head -n 500"
        
        # If successful, get more specific info
        if [[ -f "${output_file}" ]] && ! grep -q "Timeout" "${output_file}"; then
            log_message "${CYAN}  [+] SNMP responds to community: ${community}${NC}"
            
            # Get system info
            run_tool "snmpwalk sysDescr" "${OUTPUT_DIR}/logs/${safe_name}_snmp_sysinfo.txt" \
                "snmpwalk -v2c -c ${community} ${target} sysDescr.0"
            
            # Get user accounts (hrSWRunName)
            run_tool "snmpwalk processes" "${OUTPUT_DIR}/logs/${safe_name}_snmp_processes.txt" \
                "snmpwalk -v2c -c ${community} ${target} hrSWRunName 2>&1 | head -n 100"
        fi
    done
}

enumerate_with_snmpcheck() {
    local target="$1"
    local safe_name="$2"
    local output_file="${OUTPUT_DIR}/logs/${safe_name}_snmpcheck.txt"
    
    log_message "${GREEN}[*] Running snmp-check on ${target}${NC}"
    
    run_tool "snmp-check" "${output_file}" "snmp-check ${target}"
}

################################################################################
# Service-Specific Enumeration Functions
################################################################################

enumerate_smb() {
    local target="$1"
    log_message "${GREEN}[*] Enumerating SMB services${NC}"
    
    # SMB OS discovery
    run_nmap "smb_os_discovery" "${target}" "--script smb-os-discovery -p 445"
    
    # SMB enumeration
    local smb_enum_xml=$(run_nmap "smb_enum_shares" "${target}" "--script smb-enum-shares,smb-enum-users -p 445")
    
    # SMB vulnerabilities
    run_nmap "smb_vulns" "${target}" "--script smb-vuln* -p 445"
    
    # SMB protocols
    run_nmap "smb_protocols" "${target}" "--script smb-protocols,smb-security-mode -p 445"
    
    # Full SMB enumeration with additional tools
    enumerate_smb_full "${target}"
    
    # RPC enumeration
    enumerate_rpc "${target}" "445"
    
    # Parse for credentials from SMB enum results
    if [[ -f "${smb_enum_xml}" ]]; then
        # Look for credentials in output
        grep -oE "password.*" "${smb_enum_xml}" >> "${LOG_FILE}"
    fi
}

enumerate_http() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating HTTP service on port ${port}${NC}"
    
    # Determine protocol
    local protocol="http"
    if [[ "${port}" == "443" ]] || [[ "${port}" == "8443" ]]; then
        protocol="https"
    fi
    
    # HTTP enumeration with nmap
    run_nmap "http_enum_${port}" "${target}" "--script http-enum,http-headers,http-methods,http-title -p ${port}"
    
    # HTTP vulnerabilities
    run_nmap "http_vulns_${port}" "${target}" "--script http-vuln* -p ${port}"
    
    # Web technologies
    run_nmap "http_tech_${port}" "${target}" "--script http-apache-negotiation,http-apache-server-status,http-git,http-svn-enum -p ${port}"
    
    # Full web enumeration suite
    enumerate_web_full "${target}" "${port}" "${protocol}"
    
    # Extract domain and trigger DNS enumeration
    if ! [[ "${target}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if add_discovered_domain "${target}"; then
            enumerate_dns_full "${target}"
        fi
    fi
}

enumerate_ftp() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating FTP service on port ${port}${NC}"
    
    run_nmap "ftp_enum_${port}" "${target}" "--script ftp-anon,ftp-bounce,ftp-syst -p ${port}"
    run_nmap "ftp_vulns_${port}" "${target}" "--script ftp-vuln* -p ${port}"
    
    # Full FTP enumeration with ftp client
    enumerate_ftp_full "${target}" "${port}"
}

enumerate_ssh() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating SSH service on port ${port}${NC}"
    
    run_nmap "ssh_enum_${port}" "${target}" "--script ssh-hostkey,ssh-auth-methods,ssh2-enum-algos -p ${port}"
    run_nmap "ssh_vulns_${port}" "${target}" "--script ssh-vuln* -p ${port}"
}

enumerate_mysql() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating MySQL service on port ${port}${NC}"
    
    run_nmap "mysql_enum_${port}" "${target}" "--script mysql-info,mysql-databases,mysql-users,mysql-variables -p ${port}"
    run_nmap "mysql_vulns_${port}" "${target}" "--script mysql-vuln* -p ${port}"
}

enumerate_mssql() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating MSSQL service on port ${port}${NC}"
    
    run_nmap "mssql_enum_${port}" "${target}" "--script ms-sql-info,ms-sql-config,ms-sql-dump-hashes -p ${port}"
    run_nmap "mssql_vulns_${port}" "${target}" "--script ms-sql-vuln* -p ${port}"
}

enumerate_dns() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating DNS service on port ${port}${NC}"
    
    run_nmap "dns_enum_${port}" "${target}" "--script dns-nsid,dns-recursion,dns-service-discovery -p ${port}"
    run_nmap "dns_vulns_${port}" "${target}" "--script dns-cache-snoop,dns-zone-transfer -p ${port}"
    
    # Extract domain from target and trigger full DNS enumeration
    if ! [[ "${target}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        if add_discovered_domain "${target}"; then
            enumerate_dns_full "${target}"
        fi
    fi
}

enumerate_smtp() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating SMTP service on port ${port}${NC}"
    
    run_nmap "smtp_enum_${port}" "${target}" "--script smtp-commands,smtp-enum-users,smtp-open-relay -p ${port}"
    run_nmap "smtp_vulns_${port}" "${target}" "--script smtp-vuln* -p ${port}"
}

enumerate_snmp() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating SNMP service on port ${port}${NC}"
    
    run_nmap "snmp_enum_${port}" "${target}" "--script snmp-info,snmp-interfaces,snmp-processes,snmp-sysdescr -p ${port}"
    run_nmap "snmp_vulns_${port}" "${target}" "--script snmp-brute -p ${port}"
    
    # Full SNMP enumeration with additional tools
    enumerate_snmp_full "${target}" "${port}"
}

enumerate_rdp() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating RDP service on port ${port}${NC}"
    
    run_nmap "rdp_enum_${port}" "${target}" "--script rdp-enum-encryption,rdp-ntlm-info -p ${port}"
    run_nmap "rdp_vulns_${port}" "${target}" "--script rdp-vuln* -p ${port}"
}

enumerate_vnc() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating VNC service on port ${port}${NC}"
    
    run_nmap "vnc_enum_${port}" "${target}" "--script vnc-info,vnc-title -p ${port}"
}

enumerate_ldap() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating LDAP service on port ${port}${NC}"
    
    run_nmap "ldap_enum_${port}" "${target}" "--script ldap-rootdse,ldap-search -p ${port}"
}

enumerate_nfs() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating NFS service on port ${port}${NC}"
    
    run_nmap "nfs_enum_${port}" "${target}" "--script nfs-ls,nfs-showmount,nfs-statfs -p ${port}"
    
    # Full NFS enumeration with showmount
    enumerate_nfs_full "${target}"
}

enumerate_mongodb() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating MongoDB service on port ${port}${NC}"
    
    run_nmap "mongodb_enum_${port}" "${target}" "--script mongodb-info,mongodb-databases -p ${port}"
}

enumerate_redis() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating Redis service on port ${port}${NC}"
    
    run_nmap "redis_enum_${port}" "${target}" "--script redis-info -p ${port}"
}

enumerate_telnet() {
    local target="$1"
    local port="$2"
    log_message "${GREEN}[*] Enumerating Telnet service on port ${port}${NC}"
    
    run_nmap "telnet_enum_${port}" "${target}" "--script telnet-encryption,telnet-ntlm-info -p ${port}"
}

################################################################################
# Main Scanning Logic
################################################################################

perform_service_enumeration() {
    local target="$1"
    local xml_file="$2"
    
    log_message "${YELLOW}[*] Analyzing discovered services for deep enumeration${NC}"
    
    # Parse services from initial scan
    local services=$(parse_services "${xml_file}")
    local ports=$(parse_open_ports "${xml_file}")
    
    # Check for SMB
    if echo "${services}" | grep -qi "smb\|microsoft-ds\|netbios-ssn"; then
        enumerate_smb "${target}"
    fi
    
    # Check for RPC on common ports
    for rpc_port in 135 593; do
        if echo "${ports}" | grep -q "^${rpc_port}$"; then
            enumerate_rpc "${target}" "${rpc_port}"
        fi
    done
    
    # Check each port for specific services
    for port in ${ports}; do
        local service=$(check_port_service "${xml_file}" "${port}")
        
        case "${service}" in
            *http*|*ssl/http*)
                enumerate_http "${target}" "${port}"
                ;;
            *ftp*)
                enumerate_ftp "${target}" "${port}"
                ;;
            *ssh*)
                enumerate_ssh "${target}" "${port}"
                ;;
            *mysql*)
                enumerate_mysql "${target}" "${port}"
                ;;
            *ms-sql*|*mssql*)
                enumerate_mssql "${target}" "${port}"
                ;;
            *domain*|*dns*)
                enumerate_dns "${target}" "${port}"
                ;;
            *smtp*)
                enumerate_smtp "${target}" "${port}"
                ;;
            *snmp*)
                enumerate_snmp "${target}" "${port}"
                ;;
            *rdp*|*ms-wbt-server*)
                enumerate_rdp "${target}" "${port}"
                ;;
            *vnc*)
                enumerate_vnc "${target}" "${port}"
                ;;
            *ldap*)
                enumerate_ldap "${target}" "${port}"
                ;;
            *nfs*|*rpcbind*)
                enumerate_nfs "${target}" "${port}"
                enumerate_rpc "${target}" "${port}"
                ;;
            *mongodb*)
                enumerate_mongodb "${target}" "${port}"
                ;;
            *redis*)
                enumerate_redis "${target}" "${port}"
                ;;
            *telnet*)
                enumerate_telnet "${target}" "${port}"
                ;;
            *msrpc*|*ms-rpc*)
                enumerate_rpc "${target}" "${port}"
                ;;
        esac
    done
}

################################################################################
# Report Generation Functions
################################################################################

generate_report() {
    local target="$1"
    local initial_scan_xml="$2"
    
    log_message "${GREEN}[*] Generating penetration test report...${NC}"
    
    cat > "${REPORT_FILE}" << 'REPORT_HEADER'
# Automated Penetration Test Report

**Generated:** $(date '+%Y-%m-%d %H:%M:%S')  
**Target:** ${target}  
**Tool:** auto_nmap.sh v2.0

---

## Executive Summary

This report contains the findings from an automated enumeration scan of the target system(s). 
The scan was performed using the auto_nmap.sh automation script which integrates multiple 
reconnaissance and enumeration tools.

---

## Table of Contents

1. [Scan Summary](#scan-summary)
2. [Open Ports and Services](#open-ports-and-services)
3. [Discovered Domains](#discovered-domains)
4. [Discovered Credentials](#discovered-credentials)
5. [Virtual Hosts](#virtual-hosts)
6. [SMB/Share Information](#smbshare-information)
7. [Recommendations](#recommendations)
8. [Tool Output Files](#tool-output-files)

---

## Scan Summary

REPORT_HEADER

    # Add scan target info
    echo "| Parameter | Value |" >> "${REPORT_FILE}"
    echo "|-----------|-------|" >> "${REPORT_FILE}"
    echo "| Target | ${target} |" >> "${REPORT_FILE}"
    echo "| Scan Date | $(date '+%Y-%m-%d %H:%M:%S') |" >> "${REPORT_FILE}"
    echo "| Output Directory | ${OUTPUT_DIR} |" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    
    # Open Ports Section
    echo "## Open Ports and Services" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "| Port | Service | Version |" >> "${REPORT_FILE}"
    echo "|------|---------|---------|" >> "${REPORT_FILE}"
    
    if [[ -f "${initial_scan_xml}" ]]; then
        grep -oP 'portid="\K[0-9]+' "${initial_scan_xml}" | while read -r port; do
            local service=$(grep "portid=\"${port}\"" "${initial_scan_xml}" | grep -oP 'service name="\K[^"]+' | head -1)
            local version=$(grep "portid=\"${port}\"" "${initial_scan_xml}" | grep -oP 'product="\K[^"]+' | head -1)
            echo "| ${port} | ${service:-unknown} | ${version:--} |" >> "${REPORT_FILE}"
        done
    fi
    echo "" >> "${REPORT_FILE}"
    
    # Discovered Domains Section
    echo "## Discovered Domains" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    if [[ -f "${DOMAINS_FILE}" ]] && [[ -s "${DOMAINS_FILE}" ]]; then
        cat "${DOMAINS_FILE}" | while read -r domain; do
            echo "- ${domain}" >> "${REPORT_FILE}"
        done
    else
        echo "_No additional domains discovered._" >> "${REPORT_FILE}"
    fi
    echo "" >> "${REPORT_FILE}"
    
    # Discovered Credentials Section
    echo "## Discovered Credentials" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "⚠️ **SENSITIVE INFORMATION** - Handle with care" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    if [[ -f "${CREDENTIALS_FILE}" ]] && [[ -s "${CREDENTIALS_FILE}" ]]; then
        echo '```' >> "${REPORT_FILE}"
        cat "${CREDENTIALS_FILE}" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
    else
        echo "_No credentials discovered during automated scanning._" >> "${REPORT_FILE}"
    fi
    echo "" >> "${REPORT_FILE}"
    
    # Virtual Hosts Section
    echo "## Virtual Hosts" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    if [[ -f "${VHOSTS_FILE}" ]] && [[ -s "${VHOSTS_FILE}" ]]; then
        echo "The following virtual hosts were discovered:" >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
        cat "${VHOSTS_FILE}" | while read -r vhost; do
            echo "- ${vhost}" >> "${REPORT_FILE}"
        done
        echo "" >> "${REPORT_FILE}"
        echo "### Suggested /etc/hosts Entries" >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
        cat "${HOSTS_ENTRIES_FILE}" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
    else
        echo "_No virtual hosts discovered._" >> "${REPORT_FILE}"
    fi
    echo "" >> "${REPORT_FILE}"
    
    # SMB/Share Information
    echo "## SMB/Share Information" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    if [[ -f "${OUTPUT_DIR}/discovered_shares.txt" ]] && [[ -s "${OUTPUT_DIR}/discovered_shares.txt" ]]; then
        echo '```' >> "${REPORT_FILE}"
        cat "${OUTPUT_DIR}/discovered_shares.txt" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
    else
        echo "_No SMB shares discovered._" >> "${REPORT_FILE}"
    fi
    echo "" >> "${REPORT_FILE}"
    
    # NFS Exports
    if [[ -f "${OUTPUT_DIR}/discovered_nfs_exports.txt" ]] && [[ -s "${OUTPUT_DIR}/discovered_nfs_exports.txt" ]]; then
        echo "### NFS Exports" >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
        cat "${OUTPUT_DIR}/discovered_nfs_exports.txt" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
    fi
    
    # Users
    if [[ -f "${OUTPUT_DIR}/discovered_users.txt" ]] && [[ -s "${OUTPUT_DIR}/discovered_users.txt" ]]; then
        echo "### Discovered Users" >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
        cat "${OUTPUT_DIR}/discovered_users.txt" >> "${REPORT_FILE}"
        echo '```' >> "${REPORT_FILE}"
        echo "" >> "${REPORT_FILE}"
    fi
    
    # Recommendations Section
    echo "## Recommendations" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "Based on the automated scan results, consider the following next steps:" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "1. **Manual Verification**: Verify all findings manually before exploitation" >> "${REPORT_FILE}"
    echo "2. **Credential Testing**: Test discovered credentials against all services" >> "${REPORT_FILE}"
    echo "3. **Web Application Testing**: Perform detailed web application security testing" >> "${REPORT_FILE}"
    echo "4. **Vulnerability Scanning**: Run targeted vulnerability scans based on service versions" >> "${REPORT_FILE}"
    echo "5. **Documentation**: Document all findings in the case folder" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    
    # Tool Output Files
    echo "## Tool Output Files" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "All scan outputs are stored in the following locations:" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo "| Directory | Contents |" >> "${REPORT_FILE}"
    echo "|-----------|----------|" >> "${REPORT_FILE}"
    echo "| scans/ | Nmap XML, nmap, gnmap outputs |" >> "${REPORT_FILE}"
    echo "| logs/ | Tool-specific output logs |" >> "${REPORT_FILE}"
    echo "| evidence/ | Screenshots and proof files |" >> "${REPORT_FILE}"
    echo "| loot/ | Exfiltrated files and data |" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    
    # List key files
    echo "### Key Output Files" >> "${REPORT_FILE}"
    echo "" >> "${REPORT_FILE}"
    echo '```' >> "${REPORT_FILE}"
    find "${OUTPUT_DIR}" -type f -name "*.txt" -o -name "*.xml" -o -name "*.log" 2>/dev/null | \
        sed "s|${OUTPUT_DIR}/||" | sort >> "${REPORT_FILE}"
    echo '```' >> "${REPORT_FILE}"
    
    log_message "${GREEN}[+] Report generated: ${REPORT_FILE}${NC}"
}

show_help() {
    echo "Usage: $0 <target> [options]"
    echo ""
    echo "Automated Nmap Enumeration Script v2.0"
    echo "Progressively scans targets and automatically runs service-specific scans"
    echo ""
    echo "Target formats:"
    echo "  IP address:        192.168.1.1"
    echo "  IP range:          192.168.1.0/24"
    echo "  Hostname:          example.com"
    echo "  Hostname:Port:     example.com:8080"
    echo "  Full URL:          https://example.com:8443"
    echo "  Full URL with path: https://api.example.com:8443/v1"
    echo ""
    echo "Options:"
    echo "  -h, --help         Show this help message and exit"
    echo "  -o, --output DIR   Specify output directory (enables resume if exists)"
    echo "  --quick            Fast scan (top 100 ports)"
    echo "  --full             Full scan (all 65535 ports)"
    echo "  --udp              Include UDP scan"
    echo "  --no-report        Skip report generation"
    echo "  --dir-bruteforce   Enable web directory bruteforcing"
    echo ""
    echo "Examples:"
    echo "  $0 192.168.1.1"
    echo "  $0 example.com"
    echo "  $0 example.com:8080"
    echo "  $0 https://api.example.com:8443"
    echo "  $0 192.168.1.0/24 --full --udp"
    echo "  $0 192.168.1.1 -o /path/to/output    # Resume previous scan"
    echo ""
    echo "Integrated tools:"
    echo "  nmap, curl, dig, dnsenum, dnsrecon, enum4linux, finalrecon, ftp,"
    echo "  gobuster, nikto, onesixtyone, rpcclient, showmount, smbclient,"
    echo "  smbmap, snmpwalk, snmp-check, wafw00f, wappalyzer, whatweb"
    echo ""
}

main() {
    # Check for help flag first (before requiring target)
    for arg in "$@"; do
        case "$arg" in
            -h|--help)
                show_help
                exit 0
                ;;
        esac
    done
    
    # Show help if no arguments provided
    if [[ $# -eq 0 ]]; then
        show_help
        exit 1
    fi
    
    local raw_target="$1"
    shift
    local scan_mode="default"
    local include_udp=false
    local generate_report_flag=true
    local dir_bruteforce=false
    
    # Parse options
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                CUSTOM_OUTPUT_DIR="$2"
                shift 2
                ;;
            --quick)
                scan_mode="quick"
                shift
                ;;
            --full)
                scan_mode="full"
                shift
                ;;
            --udp)
                include_udp=true
                shift
                ;;
            --no-report)
                generate_report_flag=false
                shift
                ;;
            --dir-bruteforce)
                dir_bruteforce=true
                shift
                ;;
            *)
                echo "Unknown option: $1"
                exit 1
                ;;
        esac
    done
    
    # Initialize output directory (handles resume)
    init_output_dir
    
    # Parse the target
    local parsed_target=$(parse_target "${raw_target}")
    local scan_target=$(get_scan_target "${parsed_target}")
    local specified_protocol=$(get_protocol "${parsed_target}")
    local specified_port=$(get_port "${parsed_target}")
    local url_path=$(get_path "${parsed_target}")
    
    log_message "${GREEN}================================${NC}"
    log_message "${GREEN}Automated Nmap Enumeration v2.0${NC}"
    log_message "${GREEN}================================${NC}"
    log_message "Raw Input: ${raw_target}"
    log_message "Scan Target: ${scan_target}"
    
    if has_protocol "${parsed_target}"; then
        log_message "Protocol: ${specified_protocol}"
    fi
    
    if has_specific_port "${parsed_target}"; then
        log_message "Specified Port: ${specified_port}"
    fi
    
    if [[ -n "${url_path}" ]]; then
        log_message "URL Path: ${url_path}"
    fi
    
    log_message "Output Directory: ${OUTPUT_DIR}"
    log_message "Scan Mode: ${scan_mode}"
    
    if [[ "${RESUME_MODE}" == true ]]; then
        log_message "${CYAN}Resume Mode: ENABLED${NC}"
    fi
    
    log_message ""
    
    # If a specific URL was provided, run web enumeration immediately
    if has_protocol "${parsed_target}" && has_specific_port "${parsed_target}"; then
        log_message "${CYAN}[*] Detected full URL - running immediate web enumeration${NC}"
        local full_url="${specified_protocol}://${scan_target}:${specified_port}${url_path}"
        enumerate_web_full "${scan_target}" "${specified_port}" "${specified_protocol}"
        
        # Directory bruteforcing if enabled
        if [[ "${dir_bruteforce}" == true ]]; then
            enumerate_with_gobuster_dir "${full_url}" "${scan_target//\//_}_${specified_port}"
        fi
        
        # Also trigger DNS enumeration on the hostname
        if ! [[ "${scan_target}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            if add_discovered_domain "${scan_target}"; then
                enumerate_dns_full "${scan_target}"
            fi
        fi
    fi
    
    # Phase 1: Host Discovery
    log_message "${YELLOW}[Phase 1] Host Discovery${NC}"
    local discovery_xml=$(run_nmap "host_discovery" "${scan_target}" "-sn -PE -PP -PM -PO")
    
    # Phase 2: Port Scan
    log_message "${YELLOW}[Phase 2] Port Discovery${NC}"
    local port_scan_args=""
    
    # If a specific port was provided, focus on that port
    if has_specific_port "${parsed_target}"; then
        log_message "${CYAN}[*] Focusing on specified port: ${specified_port}${NC}"
        port_scan_args="-sS -sV -p ${specified_port} -T4"
    else
        case "${scan_mode}" in
            quick)
                port_scan_args="-sS -sV --top-ports 100 -T4"
                ;;
            full)
                port_scan_args="-sS -sV -p- -T4"
                ;;
            *)
                port_scan_args="-sS -sV -T4"
                ;;
        esac
    fi
    
    local initial_scan_xml=$(run_nmap "initial_scan" "${scan_target}" "${port_scan_args}")
    
    # Phase 3: UDP Scan (if requested and no specific port)
    if [[ "${include_udp}" == true ]] && ! has_specific_port "${parsed_target}"; then
        log_message "${YELLOW}[Phase 3] UDP Port Scan${NC}"
        run_nmap "udp_scan" "${scan_target}" "-sU --top-ports 100 -T4"
    fi
    
    # Phase 4: Service Enumeration
    log_message "${YELLOW}[Phase 4] Service-Specific Enumeration${NC}"
    perform_service_enumeration "${scan_target}" "${initial_scan_xml}"
    
    # Phase 5: Vulnerability Scan (skip if only targeting specific port/URL)
    if ! has_specific_port "${parsed_target}"; then
        log_message "${YELLOW}[Phase 5] Vulnerability Assessment${NC}"
        run_nmap "vuln_scan" "${scan_target}" "-sV --script vuln"
        
        # Phase 6: OS Detection
        log_message "${YELLOW}[Phase 6] OS Detection${NC}"
        run_nmap "os_detection" "${scan_target}" "-O --osscan-guess"
    else
        log_message "${YELLOW}[Phase 5] Skipping full vulnerability and OS scans (specific port targeted)${NC}"
    fi
    
    # Phase 7: Report Generation
    if [[ "${generate_report_flag}" == true ]]; then
        log_message "${YELLOW}[Phase 7] Report Generation${NC}"
        generate_report "${scan_target}" "${initial_scan_xml}"
    fi
    
    # Summary
    log_message ""
    log_message "${GREEN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    log_message "${GREEN}║                      SCAN COMPLETE                               ║${NC}"
    log_message "${GREEN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    log_message ""
    log_message "${WHITE}Output Directory:${NC} ${OUTPUT_DIR}"
    log_message ""
    
    # Port summary
    log_message "${WHITE}Open Ports Found:${NC}"
    parse_open_ports "${initial_scan_xml}" | while read port; do
        local service=$(check_port_service "${initial_scan_xml}" "${port}")
        log_message "  ${GREEN}●${NC} Port ${port}: ${service}"
    done
    
    log_message ""
    
    # Statistics
    local scan_count=${#COMPLETED_SCANS[@]}
    local domain_count=$(wc -l < "${DOMAINS_FILE}" 2>/dev/null || echo "0")
    local vhost_count=$(wc -l < "${VHOSTS_FILE}" 2>/dev/null || echo "0")
    local cred_count=$(grep -c "User:" "${CREDENTIALS_FILE}" 2>/dev/null || echo "0")
    local user_count=$(wc -l < "${OUTPUT_DIR}/discovered_users.txt" 2>/dev/null || echo "0")
    local share_count=$(wc -l < "${OUTPUT_DIR}/discovered_shares.txt" 2>/dev/null || echo "0")
    
    log_message "${WHITE}Discovery Statistics:${NC}"
    log_message "  Scans Completed:       ${scan_count}"
    log_message "  Domains Discovered:    ${domain_count}"
    log_message "  Virtual Hosts:         ${vhost_count}"
    log_message "  Credentials Found:     ${cred_count}"
    log_message "  Users Discovered:      ${user_count}"
    log_message "  Shares Found:          ${share_count}"
    log_message ""
    
    # Display important findings
    if [[ "${cred_count}" -gt 0 ]]; then
        log_message "${MAGENTA}╔══════════════════════════════════════════════════════════════════╗${NC}"
        log_message "${MAGENTA}║  ⚠️  CREDENTIALS DISCOVERED - Review ${CREDENTIALS_FILE}${NC}"
        log_message "${MAGENTA}╚══════════════════════════════════════════════════════════════════╝${NC}"
    fi
    
    if [[ "${vhost_count}" -gt 0 ]]; then
        log_message "${YELLOW}╔══════════════════════════════════════════════════════════════════╗${NC}"
        log_message "${YELLOW}║  📝 VIRTUAL HOSTS FOUND - Update /etc/hosts                      ║${NC}"
        log_message "${YELLOW}║  Suggested entries: ${HOSTS_ENTRIES_FILE}${NC}"
        log_message "${YELLOW}╚══════════════════════════════════════════════════════════════════╝${NC}"
    fi
    
    log_message ""
    log_message "${WHITE}Key Files:${NC}"
    log_message "  Log file:       ${LOG_FILE}"
    log_message "  Commands:       ${COMMANDS_FILE}"
    if [[ "${generate_report_flag}" == true ]]; then
        log_message "  Report:         ${REPORT_FILE}"
    fi
    log_message ""
    
    # Resume instructions
    log_message "${CYAN}To resume this scan later, run:${NC}"
    log_message "  $0 ${raw_target} -o ${OUTPUT_DIR}"
    log_message ""
    
    log_message "${GREEN}All enumeration complete!${NC}"
}

# Run main function
main "$@"