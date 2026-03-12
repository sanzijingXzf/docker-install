#!/bin/bash
# 使用 set -e 但允许关键步骤有错误处理
set -e
# 定义错误处理函数
handle_error() {
  local exit_code=$?
  if [[ $exit_code -ne 0 ]]; then
    echo "❌ 命令执行失败，退出码: $exit_code"
    return $exit_code
  fi
  return 0
}

# ============================================================================
# 免责声明 / Disclaimer
# ============================================================================
# 本脚本为开源代码，仅供学习和参考使用。
# 使用本脚本前，请务必：
#   1. 在本地测试环境充分测试，确认脚本功能符合预期
#   2. 在生产环境使用前，备份重要数据和配置
#   3. 了解脚本执行的操作及其可能产生的影响
#
# 虽然脚本经过充分测试，但由于系统环境差异、网络状况等因素，
# 无法保证在所有环境下都能完美运行。使用本脚本所产生的任何后果，
# 包括但不限于数据丢失、服务中断等，均由使用者自行承担。
#
# This script is open source code, provided for learning and reference purposes only.
# Before using this script, please:
#   1. Fully test in a local test environment to ensure the script functions as expected
#   2. Backup important data and configurations before using in production environments
#   3. Understand the operations performed by the script and their potential impacts
#
# Although the script has been thoroughly tested, due to differences in system
# environments, network conditions, and other factors, we cannot guarantee
# perfect operation in all environments. Any consequences arising from the use
# of this script, including but not limited to data loss and service interruptions,
# shall be borne by the user.
# ============================================================================

# 检查是否安装了 sudo，如果没有则创建一个函数来模拟 sudo
if ! command -v sudo &> /dev/null; then
    echo "⚠️  未检测到 sudo 命令，将直接使用 root 权限执行命令"
    # 创建一个模拟 sudo 的函数
    sudo() {
        "$@"
    }
    export -f sudo
else
    echo "✅ 检测到 sudo 命令"
fi

echo "=========================================="
echo "🐳 欢迎使用轩辕镜像 Docker 一键安装配置脚本"
echo "=========================================="
echo "官方网站: https://xuanyuan.cloud/"
echo ""
echo "请选择操作模式："
echo "1) 一键安装配置（推荐）"
echo "2) 修改轩辕镜像专属域名"
echo ""
# 循环等待用户输入有效选择
while true; do
    read -p "请输入选择 [1/2]: " mode_choice
    
    if [[ "$mode_choice" == "1" ]]; then
        echo ""
        echo ">>> 模式：一键安装配置"
        
        # 检查是否已经安装了 Docker
        if command -v docker &> /dev/null; then
            DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
            echo ""
            echo "⚠️  检测到系统已安装 Docker 版本: $DOCKER_VERSION"
            echo ""
            echo "⚠️  重要提示："
            echo "   选择此选项将进行 Docker 升级或重装操作"
            echo "   这可能会影响现有的 Docker 容器和数据"
            echo "   建议在操作前备份重要的容器和数据"
            echo ""
            echo "请确认是否继续："
            echo "1) 确认继续安装/升级 Docker"
            echo "2) 返回选择菜单"
            echo ""
            
            # 循环等待用户输入有效选择
            while true; do
                read -p "请输入选择 [1/2]: " confirm_choice
                
                if [[ "$confirm_choice" == "1" ]]; then
                    echo ""
                    echo "✅ 用户确认继续，将进行 Docker 安装/升级..."
                    echo ""
                    break
                elif [[ "$confirm_choice" == "2" ]]; then
                    echo ""
                    echo "🔄 返回选择菜单..."
                    echo ""
                    # 重新显示菜单选项
                    echo "请选择操作模式："
                    echo "1) 一键安装配置（推荐）"
                    echo "2) 修改轩辕镜像专属域名"
                    echo ""
                    # 重置 mode_choice 以重新进入循环
                    mode_choice=""
                    break
                else
                    echo "❌ 无效选择，请输入 1 或 2"
                    echo ""
                fi
            done
            
            # 如果用户选择了返回菜单，继续外层循环
            if [[ "$confirm_choice" == "2" ]]; then
                continue
            fi
        fi
        
        echo ""
        break
    elif [[ "$mode_choice" == "2" ]]; then
        echo ""
        echo ">>> 模式：仅修改镜像地址"
        echo ""
        
        # 检查 Docker 是否已安装
        if ! command -v docker &> /dev/null; then
            echo "❌ 检测到 Docker 未安装！"
            echo ""
            echo "⚠️  风险提示："
            echo "   - 无法验证镜像配置是否生效"
            echo "   - 可能导致后续 Docker 操作失败"
            echo "   - 建议先完成 Docker 安装"
            echo ""
            echo "💡 建议：选择选项 1 进行一键安装配置"
            echo ""
            echo "已退出脚本，请重新运行并选择选项 1 进行完整安装配置"
            exit 1
        else
            # 检查 Docker 版本
            DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
            MAJOR_VERSION=$(echo $DOCKER_VERSION | cut -d. -f1)
            
            if [[ "$MAJOR_VERSION" -lt 20 ]]; then
                echo "⚠️  检测到 Docker 版本 $DOCKER_VERSION 低于 20.0"
                echo ""
                echo "⚠️  风险提示："
                echo "   - 低版本 Docker 可能存在安全漏洞"
                echo "   - 某些新功能可能不可用"
                echo "   - 建议升级到 Docker 20+ 版本"
                echo ""
                echo "💡 建议：选择选项 1 进行一键安装配置和升级"
                echo ""
                read -p "是否仍要继续？[y/N]: " continue_choice
                if [[ ! "$continue_choice" =~ ^[Yy]$ ]]; then
                    echo "已取消操作，建议选择选项 1 进行完整安装配置"
                    exit 0
                fi
            fi
        fi
        
        echo ""
        echo ">>> 配置轩辕镜像地址"
        echo ""
        echo "请选择版本："
        echo "1) 轩辕镜像免费版 (专属域名: docker.xuanyuan.me)"
        echo "2) 轩辕镜像专业版 (专属域名: 专属域名 + docker.xuanyuan.me)"
        # 循环等待用户输入有效选择
        while true; do
            read -p "请输入选择 [1/2]: " choice
            if [[ "$choice" == "1" || "$choice" == "2" ]]; then
                break
            else
                echo "❌ 无效选择，请输入 1 或 2"
                echo ""
            fi
        done
        
        mirror_list=""
        
        if [[ "$choice" == "2" ]]; then
            read -p "请输入您的轩辕镜像专属域名 (访问官网获取：https://xuanyuan.cloud): " custom_domain
            
            # 清理用户输入的域名，移除协议前缀
            custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
            
            # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
            if [[ "$custom_domain" == *.xuanyuan.run ]]; then
                custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
                mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://$custom_domain_dev",
  "https://docker.xuanyuan.me"
]
EOF
)
            else
                mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://docker.xuanyuan.me"
]
EOF
)
            fi
        else
            mirror_list=$(cat <<EOF
[
  "https://docker.xuanyuan.me"
]
EOF
)
        fi
        
        # 创建 Docker 配置目录
        mkdir -p /etc/docker
        
        # 备份现有配置
        if [ -f /etc/docker/daemon.json ]; then
            sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup.$(date +%Y%m%d_%H%M%S)
            echo "✅ 已备份现有配置到 /etc/docker/daemon.json.backup.*"
        fi
        
        # 写入新配置
        
        # 根据用户选择设置 insecure-registries
        if [[ "$choice" == "2" ]]; then
          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
          if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "$custom_domain_dev",
  "docker.xuanyuan.me"
]
EOF
)
          else
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "docker.xuanyuan.me"
]
EOF
)
          fi
        else
          insecure_registries=$(cat <<EOF
[
  "docker.xuanyuan.me"
]
EOF
)
        fi

        cat <<EOF | tee /etc/docker/daemon.json
{
  "registry-mirrors": $mirror_list,
  "insecure-registries": $insecure_registries
}
EOF

# 如果没有禁用 DNS 配置且宿主机没有配置 DNS，则添加 DNS 配置
if [[ "$SKIP_DNS" != "true" ]]; then
  if grep -q "nameserver" /etc/resolv.conf; then
    echo "ℹ️  检测到系统已配置 DNS，跳过 Docker DNS 配置以避免冲突"
  else
    # 使用 jq 或 python 来修改 json 文件，避免直接覆盖
    if command -v jq &> /dev/null; then
      tmp_json=$(mktemp)
      sudo jq '. + {"dns": ["119.29.29.29", "114.114.114.114"]}' /etc/docker/daemon.json > "$tmp_json" && sudo mv "$tmp_json" /etc/docker/daemon.json
      echo "✅ 已添加 Docker DNS 配置"
    else
      # 简单的 sed 替换作为后备方案
      sudo sed -i 's/}/,\n  "dns": ["119.29.29.29", "114.114.114.114"]\n}/' /etc/docker/daemon.json
      echo "✅ 已添加 Docker DNS 配置"
    fi
  fi
fi
        
        echo "✅ 镜像配置已更新"
        echo ""
        echo "当前配置的镜像源："
        if [[ "$choice" == "2" ]]; then
            echo "  - https://$custom_domain (优先)"
            if [[ "$custom_domain" == *.xuanyuan.run ]]; then
                custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
                echo "  - https://$custom_domain_dev (备用)"
            fi
            echo "  - https://docker.xuanyuan.me (备用)"
        else
            echo "  - https://docker.xuanyuan.me"
        fi
        echo ""
        
        # 如果 Docker 服务正在运行，重启以应用配置
        if systemctl is-active --quiet docker 2>/dev/null; then
            echo "正在重启 Docker 服务以应用新配置..."
            systemctl daemon-reexec || true
            systemctl restart docker || true
            
            # 等待服务启动
            sleep 3
            
            if systemctl is-active --quiet docker; then
                echo "✅ Docker 服务重启成功，新配置已生效"
            else
                echo "❌ Docker 服务重启失败，请手动重启"
            fi
        else
            echo "⚠️  Docker 服务未运行，配置将在下次启动时生效"
        fi
        
        echo ""
        echo "🎉 镜像配置完成！"
        exit 0
    else
        echo "❌ 无效选择，请输入 1 或 2"
        echo ""
    fi
done

# 检测 macOS 和 Windows 系统
DETECTED_OS=$(uname -s 2>/dev/null || echo "Unknown")

# macOS 检测
if [[ "$DETECTED_OS" == "Darwin" ]]; then
  echo "🍎 检测到 macOS 系统"
  echo ""
  echo "=========================================="
  echo "⚠️  macOS 不支持此 Linux 安装脚本"
  echo "=========================================="
  echo ""
  echo "📋 macOS 安装 Docker 的正确方式："
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "方法一：使用 Homebrew 安装（推荐）"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  1. 如果未安装 Homebrew，先安装："
  echo "     /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  echo ""
  echo "  2. 使用 Homebrew 安装 Docker Desktop："
  echo "     brew install --cask docker"
  echo ""
  echo "  3. 启动 Docker Desktop："
  echo "     打开「应用程序」文件夹，双击 Docker 图标"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "方法二：下载官方安装包"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  访问：https://www.docker.com/products/docker-desktop"
  echo "  下载 Docker Desktop for Mac (Apple Silicon 或 Intel)"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚀 配置轩辕镜像"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  1. 启动 Docker Desktop"
  echo "  2. 点击菜单栏 Docker 图标 → Settings (设置)"
  echo "  3. 选择 Docker Engine"
  echo "  4. 在 JSON 配置中添加："
  echo ""
  echo '  {'
  echo '    "registry-mirrors": ['
  echo '      "https://docker.xuanyuan.me"'
  echo '    ],'
  echo '    "insecure-registries": ['
  echo '      "docker.xuanyuan.me"'
  echo '    ]'
  echo '  }'
  echo ""
  echo "  5. 点击 Apply & Restart（应用并重启）"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📚 更多信息"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  官方网站：https://xuanyuan.cloud/"
  echo "  Docker 文档：https://docs.docker.com/desktop/install/mac-install/"
  echo ""
  echo "=========================================="
  exit 0
fi

# Windows 检测（Git Bash、WSL、Cygwin、MSYS2 等）
if [[ "$DETECTED_OS" == MINGW* ]] || [[ "$DETECTED_OS" == MSYS* ]] || [[ "$DETECTED_OS" == CYGWIN* ]]; then
  echo "🪟 检测到 Windows 系统"
  echo ""
  echo "=========================================="
  echo "⚠️  Windows 不支持此 Linux 安装脚本"
  echo "=========================================="
  echo ""
  echo "📋 Windows 安装 Docker 的正确方式："
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "方法一：Docker Desktop（推荐）"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  1. 访问官方网站："
  echo "     https://www.docker.com/products/docker-desktop"
  echo ""
  echo "  2. 下载 Docker Desktop for Windows"
  echo ""
  echo "  3. 运行安装程序并按提示完成安装"
  echo ""
  echo "  4. 重启计算机（如果需要）"
  echo ""
  echo "  📌 系统要求："
  echo "     - Windows 10/11 64位专业版、企业版或教育版"
  echo "     - 启用 WSL 2（Windows Subsystem for Linux 2）"
  echo "     - 启用 Hyper-V 和容器功能"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "方法二：在 WSL 2 中使用（高级用户）"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  1. 安装 WSL 2："
  echo "     wsl --install"
  echo ""
  echo "  2. 安装 Ubuntu 或其他 Linux 发行版"
  echo ""
  echo "  3. 在 WSL 2 中运行本安装脚本："
  echo "     bash <(curl -fsSL https://xuanyuan.cloud/docker.sh)"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🚀 配置轩辕镜像"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  1. 启动 Docker Desktop"
  echo "  2. 点击系统托盘 Docker 图标 → Settings (设置)"
  echo "  3. 选择 Docker Engine"
  echo "  4. 在 JSON 配置中添加："
  echo ""
  echo '  {'
  echo '    "registry-mirrors": ['
  echo '      "https://docker.xuanyuan.me"'
  echo '    ],'
  echo '    "insecure-registries": ['
  echo '      "docker.xuanyuan.me"'
  echo '    ]'
  echo '  }'
  echo ""
  echo "  5. 点击 Apply & Restart（应用并重启）"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📚 更多信息"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  官方网站：https://xuanyuan.cloud/"
  echo "  Docker 文档：https://docs.docker.com/desktop/install/windows-install/"
  echo "  WSL 2 安装：https://docs.microsoft.com/windows/wsl/install"
  echo ""
  echo "=========================================="
  exit 0
fi

echo ">>> [1/8] 检查系统信息..."
OS=$(awk -F= '/^ID=/{print $2}' /etc/os-release | tr -d '"')
ARCH=$(uname -m)
VERSION_ID=$(awk -F= '/^VERSION_ID=/{print $2}' /etc/os-release | tr -d '"')
echo "系统: $OS $VERSION_ID 架构: $ARCH"

# 映射架构标识到 Docker 官方使用的架构名称
case "$ARCH" in
  x86_64)
    DOCKER_ARCH="x86_64"
    echo "✅ 检测到 x86_64 架构（Intel/AMD 64位）"
    ;;
  aarch64|arm64)
    DOCKER_ARCH="aarch64"
    echo "✅ 检测到 ARM 64位架构（aarch64），支持鲲鹏、飞腾等处理器"
    ;;
  armv7l|armhf)
    DOCKER_ARCH="armhf"
    echo "✅ 检测到 ARM 32位硬浮点架构（armhf）"
    ;;
  armv6l|armel)
    DOCKER_ARCH="armel"
    echo "✅ 检测到 ARM 32位软浮点架构（armel）"
    ;;
  s390x)
    DOCKER_ARCH="s390x"
    echo "✅ 检测到 IBM Z 架构（s390x）"
    ;;
  ppc64le)
    DOCKER_ARCH="ppc64le"
    echo "✅ 检测到 PowerPC 64位小端架构（ppc64le）"
    ;;
  *)
    echo "⚠️  检测到架构: $ARCH"
    echo "⚠️  Docker 官方静态二进制包可能不支持此架构"
    echo "⚠️  将尝试使用 $ARCH 作为架构标识，如果下载失败请手动安装"
    DOCKER_ARCH="$ARCH"
    ;;
esac
echo "📦 Docker 将使用架构标识: $DOCKER_ARCH"

# 针对 Debian 10 和 Ubuntu 16.04 显示特殊提示
if [[ "$OS" == "debian" && "$VERSION_ID" == "10" ]]; then
  echo ""
  echo "⚠️  检测到 Debian 10 (Buster) 系统"
  echo "📋 系统状态说明："
  echo "   - Debian 10 已于 2022 年 8 月结束生命周期"
  echo "   - 官方软件源已迁移到 archive.debian.org"
  echo "   - 本脚本将自动配置国内镜像源以提高下载速度"
  echo "   - 建议考虑升级到 Debian 11+ 或 Ubuntu 20.04+"
  echo ""
  echo "🚀 优化措施："
  echo "   - 使用阿里云/腾讯云/华为云镜像源"
  echo "   - 自动检测并切换可用的镜像源"
  echo "   - 使用二进制安装方式避免包依赖问题"
  echo ""
elif [[ "$OS" == "ubuntu" && "$VERSION_ID" == "16.04" ]]; then
  echo ""
  echo "⚠️  检测到 Ubuntu 16.04 (Xenial) 系统"
  echo "📋 系统状态说明："
  echo "   - Ubuntu 16.04 已于 2021 年 4 月结束标准支持"
  echo "   - Docker 官方仓库缺少部分新组件（如 docker-buildx-plugin）"
  echo "   - 本脚本将使用二进制安装方式以确保兼容性"
  echo "   - 强烈建议升级到 Ubuntu 20.04 LTS 或 Ubuntu 22.04 LTS"
  echo ""
  echo "🚀 优化措施："
  echo "   - 使用 Docker 二进制包直接安装"
  echo "   - 自动配置多个国内镜像源"
  echo "   - 跳过不兼容的组件安装"
  echo ""
elif [[ "$OS" == "centos" && "$VERSION_ID" == "7" ]]; then
  echo ""
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo "⚠️  重要提醒：CentOS 7 生命周期已结束"
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo "⚠️  📅 2024 年 6 月 30 日：CentOS 7 结束生命周期（EOL）"
  echo "⚠️  "
  echo "⚠️  之后，不再接收官方更新或安全补丁"
  echo "⚠️  建议升级到受支持的操作系统版本"
  echo "⚠️  "
  echo "⚠️  推荐替代方案："
  echo "⚠️    - Rocky Linux 8/9（CentOS 的社区替代品）"
  echo "⚠️    - AlmaLinux 8/9（企业级长期支持）"
  echo "⚠️    - CentOS Stream 8/9（滚动发布版本）"
  echo "⚠️    - Red Hat Enterprise Linux 8/9（商业支持）"
  echo "⚠️  "
  echo "⚠️  当前将使用归档源继续安装，但强烈建议尽快升级系统"
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo ""
elif [[ "$OS" == "centos" && "$VERSION_ID" == "8" ]]; then
  echo ""
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo "⚠️  重要提醒：CentOS 8 生命周期已结束"
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo "⚠️  📅 2021 年 12 月 31 日：CentOS 8 结束生命周期（EOL）"
  echo "⚠️  "
  echo "⚠️  之后，不再接收官方更新或安全补丁"
  echo "⚠️  建议升级到受支持的操作系统版本"
  echo "⚠️  "
  echo "⚠️  推荐替代方案："
  echo "⚠️    - Rocky Linux 8/9（CentOS 的社区替代品）"
  echo "⚠️    - AlmaLinux 8/9（企业级长期支持）"
  echo "⚠️    - CentOS Stream 8/9（滚动发布版本）"
  echo "⚠️    - Red Hat Enterprise Linux 8/9（商业支持）"
  echo "⚠️  "
  echo "⚠️  当前将使用归档源继续安装，但强烈建议尽快升级系统"
  echo "⚠️  ═══════════════════════════════════════════════════════════════════════════════"
  echo ""
elif [[ "$OS" == "kylin" ]]; then
  echo ""
  echo "✅ 检测到银河麒麟操作系统 (Kylin Linux) V$VERSION_ID"
  echo "📋 系统信息："
  echo "   - Kylin Linux 基于 RHEL，与 CentOS/RHEL 兼容"
  echo "   - 使用 yum/dnf 包管理器"
  echo "   - 支持国内镜像"
  echo ""
elif [[ "$OS" == "kali" ]]; then
  echo ""
  echo "✅ 检测到 Kali Linux $VERSION_ID"
  echo "📋 系统信息："
  echo "   - Kali Linux 基于 Debian，与 Debian 完全兼容"
  echo "   - 使用 apt 包管理器"
  echo "   - 将使用 Debian 兼容的安装方法"
  echo "   - 支持国内镜像"
  echo ""
fi

echo ">>> [1.5/8] 检查 Docker 安装状态..."
if command -v docker &> /dev/null; then
    echo "检测到 Docker 已安装"
    DOCKER_VERSION=$(docker --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
    echo "当前 Docker 版本: $DOCKER_VERSION"
    
    # 提取主版本号进行比较
    MAJOR_VERSION=$(echo $DOCKER_VERSION | cut -d. -f1)
    
    if [[ "$MAJOR_VERSION" -lt 20 ]]; then
        echo "警告: 当前 Docker 版本 $DOCKER_VERSION 低于 20.0"
        echo "建议升级到 Docker 20+ 版本以获得更好的性能和功能"
        read -p "是否要升级 Docker? [y/N]: " upgrade_choice
        
        if [[ "$upgrade_choice" =~ ^[Yy]$ ]]; then
            echo "用户选择升级 Docker，继续执行安装流程..."
        else
            echo "用户选择不升级，跳过 Docker 安装"
                    echo ">>> [5/8] 配置轩辕镜像..."
        
        # 循环等待用户选择镜像版本
        while true; do
            echo "请选择版本:"
            echo "1) 轩辕镜像免费版 (专属域名: docker.xuanyuan.me)"
            echo "2) 轩辕镜像专业版 (专属域名: 专属域名 + docker.xuanyuan.me)"
            read -p "请输入选择 [1/2]: " choice
            
            if [[ "$choice" == "1" || "$choice" == "2" ]]; then
                break
            else
                echo "❌ 无效选择，请输入 1 或 2"
                echo ""
            fi
        done
        
        mirror_list=""
        
        if [[ "$choice" == "2" ]]; then
          read -p "请输入您的轩辕镜像专属域名 (访问官网获取：https://xuanyuan.cloud): " custom_domain
          
          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
          if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://$custom_domain_dev",
  "https://docker.xuanyuan.me"
]
EOF
)
          else
            mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://docker.xuanyuan.me"
]
EOF
)
          fi
        else
          mirror_list=$(cat <<EOF
[
  "https://docker.xuanyuan.me"
]
EOF
)
        fi
        
        sudo mkdir -p /etc/docker

        # 根据用户选择设置 insecure-registries
        if [[ "$choice" == "2" ]]; then
          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
          if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "$custom_domain_dev",
  "docker.xuanyuan.me"
]
EOF
)
          else
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "docker.xuanyuan.me"
]
EOF
)
          fi
        else
          insecure_registries=$(cat <<EOF
[
  "docker.xuanyuan.me"
]
EOF
)
        fi

        # 准备 DNS 配置字符串
dns_config=""
if [[ "$SKIP_DNS" != "true" ]]; then
  if ! grep -q "nameserver" /etc/resolv.conf; then
     dns_config=',
  "dns": ["119.29.29.29", "114.114.114.114"]'
  else
     echo "ℹ️  检测到系统已配置 DNS，跳过 Docker DNS 配置以避免冲突"
  fi
fi

cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "registry-mirrors": $mirror_list,
  "insecure-registries": $insecure_registries$dns_config
}
EOF
        
        sudo systemctl daemon-reexec || true
        sudo systemctl restart docker || true
        
        echo ">>> [6/8] 安装完成！"
        echo "🎉Docker 镜像已配置完成"
        echo "轩辕镜像 · 专业版 - 开发者首选的专业 Docker 镜像高效稳定拉取服务"
        echo "官方网站: https://xuanyuan.cloud/"
        
        # 显示当前配置的镜像源
        echo ""
        echo "当前配置的镜像源："
        if [[ "$choice" == "2" ]]; then
            echo "  - https://$custom_domain (优先)"
            if [[ "$custom_domain" == *.xuanyuan.run ]]; then
                custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
                echo "  - https://$custom_domain_dev (备用)"
            fi
            echo "  - https://docker.xuanyuan.me (备用)"
        else
            echo "  - https://docker.xuanyuan.me"
        fi
        echo ""
        
        # 继续执行完整的流程，不在这里退出
        fi
    else
        echo "Docker 版本 $DOCKER_VERSION 满足要求 (>= 20.0)"
        echo "跳过 Docker 安装，直接配置镜像..."
        
        echo ">>> [5/8] 配置国内镜像..."
        
        # 循环等待用户选择镜像版本
        while true; do
            echo "请选择版本:"
            echo "1) 轩辕镜像免费版 (专属域名: docker.xuanyuan.me)"
            echo "2) 轩辕镜像专业版 (专属域名: 专属域名 + docker.xuanyuan.me)"
            read -p "请输入选择 [1/2]: " choice
            
            if [[ "$choice" == "1" || "$choice" == "2" ]]; then
                break
            else
                echo "❌ 无效选择，请输入 1 或 2"
                echo ""
            fi
        done
        
        mirror_list=""
        
        if [[ "$choice" == "2" ]]; then
          read -p "请输入您的轩辕镜像专属域名 (访问官网获取：https://xuanyuan.cloud): " custom_domain

          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
          if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://$custom_domain_dev",
  "https://docker.xuanyuan.me"
]
EOF
)
          else
            mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://docker.xuanyuan.me"
]
EOF
)
          fi
        else
          mirror_list=$(cat <<EOF
[
  "https://docker.xuanyuan.me"
]
EOF
)
        fi
        
        sudo mkdir -p /etc/docker

        # 根据用户选择设置 insecure-registries
        if [[ "$choice" == "2" ]]; then
          # 清理用户输入的域名，移除协议前缀
          custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
          
          # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
          if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "$custom_domain_dev",
  "docker.xuanyuan.me"
]
EOF
)
          else
            insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "docker.xuanyuan.me"
]
EOF
)
          fi
        else
          insecure_registries=$(cat <<EOF
[
  "docker.xuanyuan.me"
]
EOF
)
        fi

        # 准备 DNS 配置字符串
dns_config=""
if [[ "$SKIP_DNS" != "true" ]]; then
  if ! grep -q "nameserver" /etc/resolv.conf; then
     dns_config=',
  "dns": ["119.29.29.29", "114.114.114.114"]'
  else
     echo "ℹ️  检测到系统已配置 DNS，跳过 Docker DNS 配置以避免冲突"
  fi
fi

cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "registry-mirrors": $mirror_list,
  "insecure-registries": $insecure_registries$dns_config
}
EOF
        
        sudo systemctl daemon-reexec || true
        sudo systemctl restart docker || true
        
        echo ">>> [6/8] 安装完成！"
        echo "🎉Docker 镜像已配置完成"
        echo "轩辕镜像 · 专业版 - 开发者首选的专业 Docker 镜像高效稳定拉取服务"
        echo "官方网站: https://xuanyuan.cloud/"
        exit 0
    fi
else
    echo "未检测到 Docker，将进行全新安装"
fi

echo ">>> [2/8] 配置国内 Docker 源..."
# 将 OS 转换为小写进行比较（支持 openEuler、openeuler 等大小写形式）
OS_LOWER=$(echo "$OS" | tr '[:upper:]' '[:lower:]')
if [[ "$OS_LOWER" == "openeuler" ]]; then
  # openEuler (欧拉操作系统) 支持
  echo "检测到 openEuler (欧拉操作系统) $VERSION_ID"
  
  # 判断使用 dnf 还是 yum
  if [[ "${VERSION_ID%%.*}" -ge 22 ]]; then
    # openEuler 22+ 使用 dnf
    PKG_MANAGER="dnf"
    CENTOS_VERSION="9"
    echo "使用 dnf 包管理器 (openEuler $VERSION_ID 使用 CentOS 9 兼容源)"
  elif [[ "${VERSION_ID%%.*}" -ge 20 ]]; then
    # openEuler 20-21 使用 dnf，基于 CentOS 8
    PKG_MANAGER="dnf"
    CENTOS_VERSION="8"
    echo "使用 dnf 包管理器 (openEuler $VERSION_ID 使用 CentOS 8 兼容源)"
  else
    # openEuler 旧版本使用 yum，基于 CentOS 7
    PKG_MANAGER="yum"
    CENTOS_VERSION="7"
    echo "使用 yum 包管理器 (openEuler $VERSION_ID 使用 CentOS 7 兼容源)"
  fi
  
  sudo $PKG_MANAGER install -y ${PKG_MANAGER}-utils
  
  # 定义切换 Docker 镜像源的函数
  switch_docker_mirror() {
    local mirror_index=$1
    local centos_version=${CENTOS_VERSION:-9}
    local repo_added=false
    
    case $mirror_index in
      1)
        echo "尝试配置阿里云 Docker 源..."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/${centos_version}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
        ;;
      2)
        echo "尝试配置腾讯云 Docker 源..."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/${centos_version}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/gpg
EOF
        ;;
      3)
        echo "尝试配置中科大 Docker 源..."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/${centos_version}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/gpg
EOF
        ;;
      4)
        echo "尝试配置清华大学 Docker 源..."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/${centos_version}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg
EOF
        ;;
      5)
        echo "尝试配置官方 Docker 源..."
        sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/${centos_version}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
        ;;
      *)
        return 1
        ;;
    esac
    
    # 清理缓存并更新
    sudo $PKG_MANAGER clean all 2>/dev/null || true
    sudo rm -rf /var/cache/dnf/* 2>/dev/null || true
    sudo rm -rf /var/cache/yum/* 2>/dev/null || true
    
    if sudo $PKG_MANAGER makecache; then
      repo_added=true
      echo "✅ Docker 源切换成功"
      return 0
    else
      echo "❌ Docker 源切换失败"
      return 1
    fi
  }
  
  # 尝试多个国内镜像源（优先华为云，因为 openEuler 是华为开发）
  echo "正在配置 Docker 源..."
  DOCKER_REPO_ADDED=false
  CURRENT_MIRROR_INDEX=0  # 0=华为云, 1=阿里云, 2=腾讯云, 3=中科大, 4=清华, 5=官方
  
  # 创建Docker仓库配置文件，使用 openEuler 兼容的 CentOS 版本
  echo "正在创建 Docker 仓库配置 (使用 CentOS ${CENTOS_VERSION} 兼容源)..."
  
  # 源1: 华为云镜像（openEuler 是华为开发，优先使用华为云）
  echo "尝试配置华为云 Docker 源..."
  sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.huaweicloud.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.huaweicloud.com/docker-ce/linux/centos/gpg
EOF
  
  if sudo $PKG_MANAGER makecache; then
    DOCKER_REPO_ADDED=true
    echo "✅ 华为云 Docker 源配置成功"
  else
    echo "❌ 华为云 Docker 源配置失败，尝试下一个源..."
  fi
  
  # 源2: 阿里云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置阿里云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 阿里云 Docker 源配置成功"
    else
      echo "❌ 阿里云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 腾讯云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置腾讯云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 腾讯云 Docker 源配置成功"
    else
      echo "❌ 腾讯云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置中科大 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 中科大 Docker 源配置成功"
    else
      echo "❌ 中科大 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置清华大学 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 清华大学 Docker 源配置成功"
    else
      echo "❌ 清华大学 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 如果所有国内源都失败，尝试官方源
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "所有国内源都失败，尝试官方源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 官方 Docker 源配置成功"
    else
      echo "❌ 官方 Docker 源也配置失败"
    fi
  fi
  
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "❌ 所有 Docker 源都配置失败，无法继续安装"
    echo "请检查网络连接或手动配置 Docker 源"
    exit 1
  fi

  echo ">>> [3/8] 安装 Docker CE 最新版..."
  
  # 检查是否安装了 iSulad（openEuler 的容器运行时，与 Docker 冲突）
  if rpm -q iSulad &>/dev/null; then
    echo "⚠️  检测到系统已安装 iSulad（openEuler 容器运行时）"
    echo "⚠️  iSulad 与 Docker CE 存在包冲突，需要卸载 iSulad 才能安装 Docker"
    echo "正在卸载 iSulad..."
    if sudo $PKG_MANAGER remove -y iSulad 2>/dev/null; then
      echo "✅ iSulad 卸载成功"
    else
      echo "⚠️  iSulad 卸载失败，将使用 --allowerasing 参数处理冲突"
    fi
  fi
  
  # 在安装 docker-ce 之前，先检查并安装 libnftables 依赖
  echo ">>> [3.1/8] 检查 libnftables 依赖..."
  if ! rpm -q libnftables >/dev/null 2>&1; then
    echo "⚠️  未检测到 libnftables，正在安装..."
    if sudo $PKG_MANAGER install -y libnftables 2>&1; then
      echo "✅ libnftables 安装成功"
    else
      echo "⚠️  libnftables 安装失败，将在安装 docker-ce 时重试"
    fi
  else
    echo "✅ libnftables 已安装"
  fi
  
  # 尝试安装 Docker，使用 --allowerasing 参数处理 runc 冲突
  # containerd.io 会替代系统的 runc，需要使用 --allowerasing 允许替换
  if sudo $PKG_MANAGER install -y --allowerasing docker-ce docker-ce-cli containerd.io docker-buildx-plugin; then
    echo "✅ Docker CE 安装成功"
  else
    echo "❌ 批量安装失败，尝试逐个安装组件（使用 --allowerasing）..."
    
    # 再次检查 libnftables（批量安装失败后）
    echo "再次检查 libnftables 依赖..."
    if ! rpm -q libnftables >/dev/null 2>&1; then
      echo "⚠️  未检测到 libnftables，正在安装..."
      if sudo $PKG_MANAGER install -y libnftables 2>&1; then
        echo "✅ libnftables 安装成功"
      else
        echo "⚠️  libnftables 安装失败"
      fi
    else
      echo "✅ libnftables 已安装"
    fi
    
    # 逐个安装组件，都使用 --allowerasing 处理冲突
    CONTAINERD_INSTALLED=false
    CONTAINERD_OUTPUT=""
    if sudo $PKG_MANAGER install -y --allowerasing containerd.io 2>&1; then
      echo "✅ containerd.io 安装成功"
      CONTAINERD_INSTALLED=true
    else
      CONTAINERD_OUTPUT=$(sudo $PKG_MANAGER install -y --allowerasing containerd.io 2>&1 || true)
      echo "❌ containerd.io 安装失败"
      
      # 检测是否是校验和错误，如果是则尝试切换镜像源
      if echo "$CONTAINERD_OUTPUT" | grep -qiE "(checksum doesn't match|校验和不匹配|Cannot download|all mirrors were already tried)"; then
        echo "⚠️  检测到下载失败或校验和不匹配，尝试切换 Docker 镜像源..."
        
        # 尝试切换其他镜像源（从阿里云开始，因为华为云已经失败）
        for mirror_idx in 1 2 3 4 5; do
          if switch_docker_mirror $mirror_idx; then
            CURRENT_MIRROR_INDEX=$mirror_idx
            echo "  - 重新尝试安装 containerd.io..."
            if sudo $PKG_MANAGER install -y --allowerasing containerd.io 2>&1; then
              echo "✅ containerd.io 安装成功（切换镜像源后）"
              CONTAINERD_INSTALLED=true
              break
            else
              echo "  ❌ 切换镜像源后仍然失败，尝试下一个镜像源..."
            fi
          fi
        done
        
        if [[ "$CONTAINERD_INSTALLED" == "false" ]]; then
          echo "❌ 所有镜像源都尝试失败，containerd.io 无法安装"
        fi
      fi
    fi
    
    if sudo $PKG_MANAGER install -y --allowerasing docker-ce-cli; then
      echo "✅ docker-ce-cli 安装成功"
    else
      echo "❌ docker-ce-cli 安装失败"
    fi
    
    DOCKER_CE_INSTALLED=false
    DOCKER_CE_OUTPUT=""
    # 使用临时变量捕获退出码，因为 tee 会改变退出码
    DOCKER_CE_INSTALL_LOG=$(sudo $PKG_MANAGER install -y --allowerasing docker-ce 2>&1 | tee /tmp/docker-ce-install.log)
    DOCKER_CE_INSTALL_STATUS=${PIPESTATUS[0]}
    
    if [[ $DOCKER_CE_INSTALL_STATUS -eq 0 ]]; then
      # 再次验证 docker-ce 是否真的安装成功
      if rpm -q docker-ce >/dev/null 2>&1; then
        echo "✅ docker-ce 安装成功"
        DOCKER_CE_INSTALLED=true
      else
        echo "⚠️  安装命令成功但 docker-ce 包未找到，可能安装失败"
        DOCKER_CE_OUTPUT="$DOCKER_CE_INSTALL_LOG"
        echo "❌ docker-ce 安装失败"
      fi
    else
      DOCKER_CE_OUTPUT="$DOCKER_CE_INSTALL_LOG"
      echo "❌ docker-ce 安装失败"
      
      # 检测是否是 libnftables 依赖问题
      if echo "$DOCKER_CE_OUTPUT" | grep -qiE "libnftables|LIBNFTABLES"; then
        echo "⚠️  检测到 libnftables 依赖问题"
        
        # 先检查 libnftables 是否已安装
        if rpm -q libnftables >/dev/null 2>&1; then
          echo "⚠️  libnftables 已安装，但版本可能不兼容，尝试升级..."
          sudo $PKG_MANAGER update -y libnftables 2>&1 || true
        else
          echo "正在尝试安装 libnftables 依赖..."
        fi
        
        # 尝试安装 libnftables（显示详细信息，不要隐藏错误）
        if sudo $PKG_MANAGER install -y libnftables 2>&1; then
          echo "✅ libnftables 安装成功，重新尝试安装 docker-ce..."
          if sudo $PKG_MANAGER install -y --allowerasing docker-ce 2>&1 | tee /tmp/docker-ce-install-retry.log; then
            echo "✅ docker-ce 安装成功（安装 libnftables 后）"
            DOCKER_CE_INSTALLED=true
          else
            echo "❌ docker-ce 安装仍然失败"
            DOCKER_CE_OUTPUT=$(cat /tmp/docker-ce-install-retry.log 2>/dev/null || echo "")
            
            # 如果仍然失败，尝试切换镜像源（不同镜像源可能有不同版本的 docker-ce）
            if echo "$DOCKER_CE_OUTPUT" | grep -qiE "libnftables|LIBNFTABLES"; then
              echo "⚠️  当前镜像源的 docker-ce 版本可能不兼容，尝试切换镜像源..."
              
              # 尝试切换其他镜像源（从阿里云开始，因为华为云已经失败）
              for mirror_idx in 1 2 3 4 5; do
                if switch_docker_mirror $mirror_idx; then
                  CURRENT_MIRROR_INDEX=$mirror_idx
                  echo "  - 重新尝试安装 docker-ce..."
                  
                  # 再次检查并安装 libnftables（某些镜像源可能提供不同版本）
                  if ! rpm -q libnftables >/dev/null 2>&1; then
                    echo "  - 安装 libnftables..."
                    sudo $PKG_MANAGER install -y libnftables 2>&1 || echo "  ⚠️  libnftables 安装失败，继续尝试安装 docker-ce..."
                  else
                    echo "  ✅ libnftables 已安装"
                  fi
                  
                  if sudo $PKG_MANAGER install -y --allowerasing docker-ce 2>&1 | tee /tmp/docker-ce-install-mirror.log; then
                    echo "✅ docker-ce 安装成功（切换镜像源后）"
                    DOCKER_CE_INSTALLED=true
                    break
                  else
                    echo "  ❌ 切换镜像源后仍然失败，尝试下一个镜像源..."
                  fi
                fi
              done
            fi
          fi
        else
          echo "⚠️  libnftables 安装失败，尝试切换镜像源后重试..."
          
          # 尝试切换其他镜像源
          for mirror_idx in 1 2 3 4 5; do
            if switch_docker_mirror $mirror_idx; then
              CURRENT_MIRROR_INDEX=$mirror_idx
              echo "  - 检查并安装 libnftables..."
              
              # 先检查是否已安装
              if rpm -q libnftables >/dev/null 2>&1; then
                echo "  ✅ libnftables 已安装"
              else
                # 尝试安装 libnftables（显示详细信息）
                if sudo $PKG_MANAGER install -y libnftables 2>&1; then
                  echo "  ✅ libnftables 安装成功"
                else
                  echo "  ⚠️  libnftables 安装失败，继续尝试安装 docker-ce..."
                fi
              fi
              
              # 无论 libnftables 是否安装成功，都尝试安装 docker-ce
              echo "  - 尝试安装 docker-ce..."
              if sudo $PKG_MANAGER install -y --allowerasing docker-ce 2>&1 | tee /tmp/docker-ce-install-mirror.log; then
                echo "✅ docker-ce 安装成功（切换镜像源后）"
                DOCKER_CE_INSTALLED=true
                break
              else
                echo "  ❌ docker-ce 安装仍然失败，尝试下一个镜像源..."
              fi
            fi
          done
          
          if [[ "$DOCKER_CE_INSTALLED" == "false" ]]; then
            echo "⚠️  所有镜像源都尝试失败，将使用二进制安装方式绕过依赖问题"
          fi
        fi
      fi
    fi
    
    if sudo $PKG_MANAGER install -y --allowerasing docker-buildx-plugin; then
      echo "✅ docker-buildx-plugin 安装成功"
    else
      echo "❌ docker-buildx-plugin 安装失败"
    fi
    
    # 检查 docker.service 文件是否存在
    DOCKER_SERVICE_EXISTS=false
    if [ -f /etc/systemd/system/docker.service ] || [ -f /usr/lib/systemd/system/docker.service ]; then
      DOCKER_SERVICE_EXISTS=true
    fi
    
    # 检查是否至少安装了核心组件
    # 不仅要检查 docker 命令是否存在，还要检查 docker.service 是否存在
    if ! command -v docker &> /dev/null || [ "$DOCKER_CE_INSTALLED" == "false" ] || [ "$DOCKER_SERVICE_EXISTS" == "false" ]; then
      if [ "$DOCKER_CE_INSTALLED" == "false" ] || [ "$DOCKER_SERVICE_EXISTS" == "false" ]; then
        if command -v docker &> /dev/null; then
          echo "⚠️  检测到 docker 命令存在，但 docker-ce 包或 docker.service 文件缺失"
          echo "⚠️  这通常是由于依赖问题导致 docker-ce 安装不完整"
        fi
        echo "❌ docker-ce 安装不完整，尝试二进制安装..."
      else
        echo "❌ 包管理器安装完全失败，尝试二进制安装..."
      fi
      
      # 二进制安装备选方案
      echo "正在下载 Docker 二进制包..."
      
      # 尝试多个下载源
      DOCKER_BINARY_DOWNLOADED=false
      
      # 源1: 华为云镜像（优先）
      echo "尝试从华为云镜像下载 Docker 二进制包..."
      if curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
        DOCKER_BINARY_DOWNLOADED=true
        echo "✅ 从华为云镜像下载成功"
      else
        echo "❌ 华为云镜像下载失败，尝试下一个源..."
      fi
      
      # 源2: 阿里云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从阿里云镜像下载..."
        if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从阿里云镜像下载成功"
        else
          echo "❌ 阿里云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源3: 腾讯云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从腾讯云镜像下载..."
        if curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从腾讯云镜像下载成功"
        else
          echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源4: 官方源
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从官方源下载..."
        if curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从官方源下载成功"
        else
          echo "❌ 官方源下载失败"
        fi
      fi
      
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "true" ]]; then
    echo "正在解压并安装 Docker 二进制包..."
    sudo tar -xzf /tmp/docker.tgz -C /usr/bin --strip-components=1
    sudo chmod +x /usr/bin/docker*
    
    # SELinux 友好提示
    if command -v getenforce &> /dev/null && [ "$(getenforce)" != "Disabled" ]; then
        echo ""
        echo "⚠️  检测到 SELinux 处于开启状态 ($(getenforce))"
        echo "⚠️  二进制安装方式可能会遇到 SELinux 上下文问题"
        echo "⚠️  如果启动失败，请尝试临时关闭 SELinux (setenforce 0) 或手动配置 SELinux 策略"
        echo "💡 推荐操作：尝试安装 container-selinux >= 2.74"
        echo ""
        echo "正在等待 3 秒以确认切换到二进制安装模式..."
        sleep 3
    fi

    # 创建 systemd 服务文件
        sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service time-set.target
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

        # 创建 docker.socket 文件
        sudo tee /etc/systemd/system/docker.socket > /dev/null <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

        # 创建 docker 用户组
        sudo groupadd docker 2>/dev/null || true
        
        echo "✅ Docker 二进制安装成功"
      else
        echo "❌ 所有下载源都失败，无法安装 Docker"
        echo "请检查网络连接或手动安装 Docker"
        exit 1
      fi
    fi
  fi
  
  # 检查 docker.service 文件是否存在
  if [ ! -f /etc/systemd/system/docker.service ] && [ ! -f /usr/lib/systemd/system/docker.service ]; then
    echo "❌ docker.service 文件不存在，Docker 服务无法启动"
    echo "⚠️  这通常是由于 docker-ce 包安装失败导致的"
    echo "💡 建议："
    echo "   1. 检查依赖问题（如 libnftables）"
    echo "   2. 尝试手动安装依赖：sudo $PKG_MANAGER install -y libnftables"
    echo "   3. 重新运行安装脚本"
    echo "   4. 或使用二进制安装方式"
    exit 1
  fi
  
  # 启动 Docker 服务
  echo "正在启动 Docker 服务..."
  if sudo systemctl enable docker 2>/dev/null; then
    echo "✅ Docker 服务已设置为开机自启"
  else
    echo "⚠️  Docker 服务开机自启设置失败"
  fi
  
  if sudo systemctl start docker 2>/dev/null; then
    echo "✅ Docker 服务启动成功"
  else
    echo "⚠️  Docker 服务启动失败，尝试查看日志..."
    sudo systemctl status docker --no-pager -l || true
    echo "💡 可以尝试手动启动：sudo dockerd &"
  fi
  
  echo ">>> [3.5/8] 安装 Docker Compose..."
  # 安装最新版本的 docker-compose，使用多个备用下载源
  echo "正在下载 Docker Compose..."
  
  # 尝试多个下载源
  DOCKER_COMPOSE_DOWNLOADED=false
  
  # 源1: 华为云镜像（优先）
  echo "尝试从华为云镜像下载..."
  if sudo curl -L "https://mirrors.huaweicloud.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
    DOCKER_COMPOSE_DOWNLOADED=true
    echo "✅ 从华为云镜像下载成功"
  else
    echo "❌ 华为云镜像下载失败，尝试下一个源..."
  fi
  
  # 源2: 阿里云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从阿里云镜像下载..."
    if sudo curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从阿里云镜像下载成功"
    else
      echo "❌ 阿里云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 腾讯云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从腾讯云镜像下载..."
    if sudo curl -L "https://mirrors.cloud.tencent.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从腾讯云镜像下载成功"
    else
      echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从中科大镜像下载..."
    if sudo curl -L "https://mirrors.ustc.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从中科大镜像下载成功"
    else
      echo "❌ 中科大镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从清华大学镜像下载..."
    if sudo curl -L "https://mirrors.tuna.tsinghua.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从清华大学镜像下载成功"
    else
      echo "❌ 清华大学镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源6: 网易镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从网易镜像下载..."
    if sudo curl -L "https://mirrors.163.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从网易镜像下载成功"
    else
      echo "❌ 网易镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源7: 最后尝试 GitHub (如果网络允许)
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从 GitHub 下载..."
    if sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从 GitHub 下载成功"
    else
      echo "❌ GitHub 下载失败"
    fi
  fi
  
  # 检查是否下载成功
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "❌ 所有下载源都失败了，尝试使用包管理器安装..."
    
    # 使用包管理器作为备选方案
    if sudo $PKG_MANAGER install -y docker-compose-plugin; then
      echo "✅ 通过包管理器安装 docker-compose-plugin 成功"
      DOCKER_COMPOSE_DOWNLOADED=true
    else
      echo "❌ 包管理器安装也失败了"
    fi
  fi
  
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "true" ]]; then
    # 设置执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接到 PATH 目录
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "✅ Docker Compose 安装完成"
  else
    echo "❌ Docker Compose 安装失败，请手动安装"
    echo "建议访问: https://docs.docker.com/compose/install/ 查看手动安装方法"
  fi

elif [[ "$OS" == "opencloudos" ]]; then
  # OpenCloudOS 9 使用 dnf 而不是 yum
  sudo dnf install -y dnf-utils
  
  # 尝试多个国内镜像源
  echo "正在配置 Docker 源..."
  DOCKER_REPO_ADDED=false
  
  # 创建Docker仓库配置文件，使用 OpenCloudOS 9 兼容的版本
  echo "正在创建 Docker 仓库配置..."
  
  # 源1: 阿里云镜像
  echo "尝试配置阿里云 Docker 源..."
  sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
  
  if sudo dnf makecache; then
    DOCKER_REPO_ADDED=true
    echo "✅ 阿里云 Docker 源配置成功"
  else
    echo "❌ 阿里云 Docker 源配置失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置腾讯云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 腾讯云 Docker 源配置成功"
    else
      echo "❌ 腾讯云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置华为云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.huaweicloud.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.huaweicloud.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 华为云 Docker 源配置成功"
    else
      echo "❌ 华为云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置中科大 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 中科大 Docker 源配置成功"
    else
      echo "❌ 中科大 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置清华大学 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 清华大学 Docker 源配置成功"
    else
      echo "❌ 清华大学 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 如果所有国内源都失败，尝试官方源
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "所有国内源都失败，尝试官方源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 官方 Docker 源配置成功"
    else
      echo "❌ 官方 Docker 源也配置失败"
    在
    fi
  fi
  
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "❌ 所有 Docker 源都配置失败，无法继续安装"
    echo "请检查网络连接或手动配置 Docker 源"
    exit 1
  fi

  echo ">>> [3/8] 安装 Docker CE 最新版..."
  
  # 临时禁用 set -e，允许错误处理
  set +e
  
  echo "正在尝试安装 Docker CE（这可能需要几分钟，请耐心等待）..."
  echo "如果安装过程卡住，可能是网络问题或依赖解析中，请等待..."
  
  # 尝试安装 Docker，使用超时机制（30分钟超时）
  INSTALL_OUTPUT=""
  INSTALL_STATUS=1
  
  # 使用 timeout 命令（如果可用）或直接执行
  # 注意：使用 bash -c 确保 sudo 函数在子 shell 中可用
  if command -v timeout &> /dev/null; then
    INSTALL_OUTPUT=$(timeout 1800 bash -c "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin" 2>&1)
    INSTALL_STATUS=$?
    if [[ $INSTALL_STATUS -eq 124 ]]; then
      echo "❌ 安装超时（30分钟），可能是网络问题或依赖解析失败"
      INSTALL_STATUS=1
    fi
  else
    INSTALL_OUTPUT=$(sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin 2>&1)
    INSTALL_STATUS=$?
  fi
  
  # 重新启用 set -e
  set -e
  
  if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo "✅ Docker CE 安装成功"
  else
    # 显示详细错误信息
    echo ""
    echo "❌ Docker CE 批量安装失败"
    echo "错误详情："
    echo "$INSTALL_OUTPUT" | tail -20
    echo ""
    
    # 检查错误类型
    if echo "$INSTALL_OUTPUT" | grep -qiE "(timeout|timed out|connection|网络|network)"; then
      echo "⚠️  检测到可能的网络问题，请检查网络连接"
    fi
    if echo "$INSTALL_OUTPUT" | grep -qiE "(repo|repository|仓库|not found|找不到)"; then
      echo "⚠️  检测到可能的仓库配置问题，请检查 Docker 源配置"
    fi
    
    echo "正在尝试逐个安装组件..."
    
    # 临时禁用 set -e
    set +e
    
    # 逐个安装组件
    echo "  - 正在安装 containerd.io..."
    CONTAINERD_OUTPUT=$(sudo dnf install -y containerd.io 2>&1)
    CONTAINERD_STATUS=$?
    if [[ $CONTAINERD_STATUS -eq 0 ]]; then
      echo "  ✅ containerd.io 安装成功"
    else
      echo "  ❌ containerd.io 安装失败"
      echo "  错误信息: $(echo "$CONTAINERD_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-ce-cli..."
    DOCKER_CLI_OUTPUT=$(sudo dnf install -y docker-ce-cli 2>&1)
    DOCKER_CLI_STATUS=$?
    if [[ $DOCKER_CLI_STATUS -eq 0 ]]; then
      echo "  ✅ docker-ce-cli 安装成功"
    else
      echo "  ❌ docker-ce-cli 安装失败"
      echo "  错误信息: $(echo "$DOCKER_CLI_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-ce..."
    DOCKER_CE_OUTPUT=$(sudo dnf install -y docker-ce 2>&1)
    DOCKER_CE_STATUS=$?
    if [[ $DOCKER_CE_STATUS -eq 0 ]]; then
      echo "  ✅ docker-ce 安装成功"
    else
      echo "  ❌ docker-ce 安装失败"
      echo "  错误信息: $(echo "$DOCKER_CE_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-buildx-plugin..."
    BUILDX_OUTPUT=$(sudo dnf install -y docker-buildx-plugin 2>&1)
    BUILDX_STATUS=$?
    if [[ $BUILDX_STATUS -eq 0 ]]; then
      echo "  ✅ docker-buildx-plugin 安装成功"
    else
      echo "  ⚠️  docker-buildx-plugin 安装失败（可选组件，不影响核心功能）"
    fi
    
    # 重新启用 set -e
    set -e
    
    # 检查是否至少安装了核心组件
    if ! command -v docker &> /dev/null; then
      echo ""
      echo "❌ 包管理器安装完全失败，尝试二进制安装..."
      
      # 二进制安装备选方案
      echo "正在下载 Docker 二进制包..."
      
      # 尝试多个下载源
      DOCKER_BINARY_DOWNLOADED=false
      
      # 源1: 阿里云镜像
      echo "尝试从阿里云镜像下载 Docker 二进制包..."
      if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
        DOCKER_BINARY_DOWNLOADED=true
        echo "✅ 从阿里云镜像下载成功"
      else
        echo "❌ 阿里云镜像下载失败，尝试下一个源..."
      fi
      
      # 源2: 腾讯云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从腾讯云镜像下载..."
        if curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从腾讯云镜像下载成功"
        else
          echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源3: 华为云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从华为云镜像下载..."
        if curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从华为云镜像下载成功"
        else
          echo "❌ 华为云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源4: 官方源
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从官方源下载..."
        if curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从官方源下载成功"
        else
          echo "❌ 官方源下载失败"
        fi
      fi
      
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "true" ]]; then
        echo "正在解压并安装 Docker 二进制包..."
        sudo tar -xzf /tmp/docker.tgz -C /usr/bin --strip-components=1
        sudo chmod +x /usr/bin/docker*
        
        # 创建 systemd 服务文件
        sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service time-set.target
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

        # 创建 docker.socket 文件
        sudo tee /etc/systemd/system/docker.socket > /dev/null <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

        # 创建 docker 用户组
        sudo groupadd docker 2>/dev/null || true
        
        echo "✅ Docker 二进制安装成功"
      else
        echo "❌ 所有下载源都失败，无法安装 Docker"
        echo "请检查网络连接或手动安装 Docker"
        exit 1
      fi
    fi
  fi
  
  sudo systemctl enable docker
  sudo systemctl start docker
  
  echo ">>> [3.5/8] 安装 Docker Compose..."
  # 安装最新版本的 docker-compose，使用多个备用下载源
  echo "正在下载 Docker Compose..."
  
  # 尝试多个下载源
  DOCKER_COMPOSE_DOWNLOADED=false
  
  # 源1: 阿里云镜像
  echo "尝试从阿里云镜像下载..."
  if sudo curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
    DOCKER_COMPOSE_DOWNLOADED=true
    echo "✅ 从阿里云镜像下载成功"
  else
    echo "❌ 阿里云镜像下载失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从腾讯云镜像下载..."
    if sudo curl -L "https://mirrors.cloud.tencent.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从腾讯云镜像下载成功"
    else
      echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从华为云镜像下载..."
    if sudo curl -L "https://mirrors.huaweicloud.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从华为云镜像下载成功"
    else
      echo "❌ 华为云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从中科大镜像下载..."
    if sudo curl -L "https://mirrors.ustc.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从中科大镜像下载成功"
    else
      echo "❌ 中科大镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从清华大学镜像下载..."
    if sudo curl -L "https://mirrors.tuna.tsinghua.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从清华大学镜像下载成功"
    else
      echo "❌ 清华大学镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源6: 网易镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从网易镜像下载..."
    if sudo curl -L "https://mirrors.163.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从网易镜像下载成功"
    else
      echo "❌ 网易镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源7: 最后尝试 GitHub (如果网络允许)
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从 GitHub 下载..."
    if sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从 GitHub 下载成功"
    else
      echo "❌ GitHub 下载失败"
    fi
  fi
  
  # 检查是否下载成功
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "❌ 所有下载源都失败了，尝试使用包管理器安装..."
    
    # 使用包管理器作为备选方案
    if sudo $PKG_MANAGER install -y docker-compose-plugin; then
      echo "✅ 通过包管理器安装 docker-compose-plugin 成功"
      DOCKER_COMPOSE_DOWNLOADED=true
    else
      echo "❌ 包管理器安装也失败了"
    fi
  fi
  
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "true" ]]; then
    # 设置执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接到 PATH 目录
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "✅ Docker Compose 安装完成"
  else
    echo "❌ Docker Compose 安装失败，请手动安装"
    echo "建议访问: https://docs.docker.com/compose/install/ 查看手动安装方法"
  fi

elif [[ "$OS" == "alinux" ]]; then
  # Alinux (Alibaba Cloud Linux) 支持
  echo "检测到 Alibaba Cloud Linux (Alinux) $VERSION_ID"
  echo "基于 Anolis OS，阿里云深度优化的企业级操作系统"
  
  # 判断使用 dnf 还是 yum
  if [[ "${VERSION_ID%%.*}" -ge 3 ]]; then
    # Alinux 3+ 使用 dnf，基于 Anolis OS 8
    PKG_MANAGER="dnf"
    CENTOS_VERSION="8"
    echo "使用 dnf 包管理器 (Alinux $VERSION_ID 基于 Anolis OS 8 / CentOS 8)"
  else
    # Alinux 2 使用 yum，基于 Anolis OS 7
    PKG_MANAGER="yum"
    CENTOS_VERSION="7"
    echo "使用 yum 包管理器 (Alinux $VERSION_ID 基于 Anolis OS 7 / CentOS 7)"
  fi
  
  sudo $PKG_MANAGER install -y ${PKG_MANAGER}-utils
  
  # 尝试多个国内镜像源
  echo "正在配置 Docker 源..."
  DOCKER_REPO_ADDED=false
  
  # 创建Docker仓库配置文件，使用 Alinux 兼容的 CentOS 版本
  echo "正在创建 Docker 仓库配置 (使用 CentOS ${CENTOS_VERSION} 兼容源)..."
  
  # 源1: 阿里云镜像
  echo "尝试配置阿里云 Docker 源..."
  sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
  
  if sudo $PKG_MANAGER makecache; then
    DOCKER_REPO_ADDED=true
    echo "✅ 阿里云 Docker 源配置成功"
  else
    echo "❌ 阿里云 Docker 源配置失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置腾讯云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 腾讯云 Docker 源配置成功"
    else
      echo "❌ 腾讯云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置华为云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.huaweicloud.com/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.huaweicloud.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 华为云 Docker 源配置成功"
    else
      echo "❌ 华为云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置中科大 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 中科大 Docker 源配置成功"
    else
      echo "❌ 中科大 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置清华大学 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 清华大学 Docker 源配置成功"
    else
      echo "❌ 清华大学 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 如果所有国内源都失败，尝试官方源
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "所有国内源都失败，尝试官方源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/${CENTOS_VERSION}/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
    
    if sudo $PKG_MANAGER makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 官方 Docker 源配置成功"
    else
      echo "❌ 官方 Docker 源也配置失败"
    fi
  fi
  
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "❌ 所有 Docker 源都配置失败，无法继续安装"
    echo "请检查网络连接或手动配置 Docker 源"
    exit 1
  fi

  echo ">>> [3/8] 安装 Docker CE 最新版..."
  
  # 尝试安装 Docker，如果失败则尝试逐个安装组件
  if sudo $PKG_MANAGER install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin; then
    echo "✅ Docker CE 安装成功"
  else
    echo "❌ 批量安装失败，尝试逐个安装组件..."
    
    # 逐个安装组件
    if sudo $PKG_MANAGER install -y containerd.io; then
      echo "✅ containerd.io 安装成功"
    else
      echo "❌ containerd.io 安装失败"
    fi
    
    if sudo $PKG_MANAGER install -y docker-ce-cli; then
      echo "✅ docker-ce-cli 安装成功"
    else
      echo "❌ docker-ce-cli 安装失败"
    fi
    
    if sudo $PKG_MANAGER install -y docker-ce; then
      echo "✅ docker-ce 安装成功"
    else
      echo "❌ docker-ce 安装失败"
    fi
    
    if sudo $PKG_MANAGER install -y docker-buildx-plugin; then
      echo "✅ docker-buildx-plugin 安装成功"
    else
      echo "❌ docker-buildx-plugin 安装失败"
    fi
    
    # 检查是否至少安装了核心组件
    if ! command -v docker &> /dev/null; then
      echo "❌ 包管理器安装完全失败，尝试二进制安装..."
      
      # 二进制安装备选方案
      echo "正在下载 Docker 二进制包..."
      
      # 尝试多个下载源
      DOCKER_BINARY_DOWNLOADED=false
      
      # 源1: 阿里云镜像
      echo "尝试从阿里云镜像下载 Docker 二进制包..."
      if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
        DOCKER_BINARY_DOWNLOADED=true
        echo "✅ 从阿里云镜像下载成功"
      else
        echo "❌ 阿里云镜像下载失败，尝试下一个源..."
      fi
      
      # 源2: 腾讯云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从腾讯云镜像下载..."
        if curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从腾讯云镜像下载成功"
        else
          echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源3: 华为云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从华为云镜像下载..."
        if curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从华为云镜像下载成功"
        else
          echo "❌ 华为云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源4: 官方源
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从官方源下载..."
        if curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从官方源下载成功"
        else
          echo "❌ 官方源下载失败"
        fi
      fi
      
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "true" ]]; then
        echo "正在解压并安装 Docker 二进制包..."
        sudo tar -xzf /tmp/docker.tgz -C /usr/bin --strip-components=1
        sudo chmod +x /usr/bin/docker*
        
        # 创建 systemd 服务文件
        sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service time-set.target
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

        # 创建 docker.socket 文件
        sudo tee /etc/systemd/system/docker.socket > /dev/null <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

        # 创建 docker 用户组
        sudo groupadd docker 2>/dev/null || true
        
        echo "✅ Docker 二进制安装成功"
      else
        echo "❌ 所有下载源都失败，无法安装 Docker"
        echo "请检查网络连接或手动安装 Docker"
        exit 1
      fi
    fi
  fi
  
  sudo systemctl enable docker
  sudo systemctl start docker
  
  echo ">>> [3.5/8] 安装 Docker Compose..."
  # 安装最新版本的 docker-compose，使用多个备用下载源
  echo "正在下载 Docker Compose..."
  
  # 尝试多个下载源
  DOCKER_COMPOSE_DOWNLOADED=false
  
  # 源1: 阿里云镜像
  echo "尝试从阿里云镜像下载..."
  if sudo curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
    DOCKER_COMPOSE_DOWNLOADED=true
    echo "✅ 从阿里云镜像下载成功"
  else
    echo "❌ 阿里云镜像下载失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从腾讯云镜像下载..."
    if sudo curl -L "https://mirrors.cloud.tencent.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从腾讯云镜像下载成功"
    else
      echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从华为云镜像下载..."
    if sudo curl -L "https://mirrors.huaweicloud.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从华为云镜像下载成功"
    else
      echo "❌ 华为云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从中科大镜像下载..."
    if sudo curl -L "https://mirrors.ustc.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从中科大镜像下载成功"
    else
      echo "❌ 中科大镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从清华大学镜像下载..."
    if sudo curl -L "https://mirrors.tuna.tsinghua.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从清华大学镜像下载成功"
    else
      echo "❌ 清华大学镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源6: 网易镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从网易镜像下载..."
    if sudo curl -L "https://mirrors.163.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从网易镜像下载成功"
    else
      echo "❌ 网易镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源7: 最后尝试 GitHub (如果网络允许)
  # 源7: 最后尝试 GitHub (如果网络允许)
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从 GitHub 下载..."
    if sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从 GitHub 下载成功"
    else
      echo "❌ GitHub 下载失败"
    在
    fi
  fi
  
  # 检查是否下载成功
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "❌ 所有下载源都失败了，尝试使用包管理器安装..."
    
    # 使用包管理器作为备选方案
    if sudo dnf install -y docker-compose-plugin; then
      echo "✅ 通过包管理器安装 docker-compose-plugin 成功"
      DOCKER_COMPOSE_DOWNLOADED=true
    else
      echo "❌ 包管理器安装也失败了"
    fi
  fi
  
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "true" ]]; then
    # 设置执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接到 PATH 目录
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "✅ Docker Compose 安装完成"
  else
    echo "❌ Docker Compose 安装失败，请手动安装"
    echo "建议访问: https://docs.docker.com/compose/install/ 查看手动安装方法"
  fi

elif [[ "$OS" == "fedora" ]]; then
  # Fedora 支持
  echo "检测到 Fedora $VERSION_ID"
  
  # 检查 Fedora 版本是否过期
  if [[ "${VERSION_ID%%.*}" -lt 38 ]]; then
    echo ""
    echo "⚠️  警告：Fedora $VERSION_ID 可能已结束生命周期"
    echo "📋 建议："
    echo "   - 升级到 Fedora 38+ 以获得最新的安全更新和软件包"
    echo "   - 或考虑使用 Rocky Linux / AlmaLinux（企业级长期支持）"
    echo ""
  fi
  
  # Fedora 使用 dnf 包管理器
  sudo dnf install -y dnf-plugins-core
  
  # 尝试多个国内镜像源
  echo "正在配置 Docker 源..."
  DOCKER_REPO_ADDED=false
  
  # 创建Docker仓库配置文件，使用 Fedora 专用仓库
  echo "正在创建 Docker 仓库配置..."
  
  # 源1: 阿里云镜像
  echo "尝试配置阿里云 Docker 源..."
  sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/fedora/gpg
EOF
  
  if sudo dnf makecache; then
    DOCKER_REPO_ADDED=true
    echo "✅ 阿里云 Docker 源配置成功"
  else
    echo "❌ 阿里云 Docker 源配置失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置腾讯云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/fedora/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 腾讯云 Docker 源配置成功"
    else
      echo "❌ 腾讯云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置华为云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.huaweicloud.com/docker-ce/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.huaweicloud.com/docker-ce/linux/fedora/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 华为云 Docker 源配置成功"
    else
      echo "❌ 华为云 Docker 源配置失败，尝试下一个源..."
    在
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置中科大 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/fedora/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 中科大 Docker 源配置成功"
    else
      echo "❌ 中科大 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置清华大学 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/fedora/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 清华大学 Docker 源配置成功"
    else
      echo "❌ 清华大学 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 如果所有国内源都失败，尝试官方源
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "所有国内源都失败，尝试官方源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/fedora/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/fedora/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 官方 Docker 源配置成功"
    else
      echo "❌ 官方 Docker 源也配置失败"
    fi
  fi
  
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "❌ 所有 Docker 源都配置失败，无法继续安装"
    echo "请检查网络连接或手动配置 Docker 源"
    exit 1
  fi

  echo ">>> [3/8] 安装 Docker CE 最新版..."
  
  # 尝试安装 Docker，如果失败则尝试逐个安装组件
  if sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; then
    echo "✅ Docker CE 安装成功"
  else
    echo "❌ 批量安装失败，尝试逐个安装组件..."
    
    # 逐个安装组件
    if sudo dnf install -y containerd.io; then
      echo "✅ containerd.io 安装成功"
    else
      echo "❌ containerd.io 安装失败"
    fi
    
    if sudo dnf install -y docker-ce-cli; then
      echo "✅ docker-ce-cli 安装成功"
    else
      echo "❌ docker-ce-cli 安装失败"
    fi
    
    if sudo dnf install -y docker-ce; then
      echo "✅ docker-ce 安装成功"
    else
      echo "❌ docker-ce 安装失败"
    fi
    
    if sudo dnf install -y docker-buildx-plugin; then
      echo "✅ docker-buildx-plugin 安装成功"
    else
      echo "❌ docker-buildx-plugin 安装失败（可选组件）"
    fi
    
    if sudo dnf install -y docker-compose-plugin; then
      echo "✅ docker-compose-plugin 安装成功"
    else
      echo "❌ docker-compose-plugin 安装失败（可选组件）"
    fi
    
    # 检查是否至少安装了核心组件
    if ! command -v docker &> /dev/null; then
      echo "❌ 包管理器安装完全失败，尝试二进制安装..."
      
      # 二进制安装备选方案
      echo "正在下载 Docker 二进制包..."
      
      # 尝试多个下载源
      DOCKER_BINARY_DOWNLOADED=false
      
      # 源1: 阿里云镜像
      echo "尝试从阿里云镜像下载 Docker 二进制包..."
      if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
        DOCKER_BINARY_DOWNLOADED=true
        echo "✅ 从阿里云镜像下载成功"
      else
        echo "❌ 阿里云镜像下载失败，尝试下一个源..."
      fi
      
      # 源2: 腾讯云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从腾讯云镜像下载..."
        if curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从腾讯云镜像下载成功"
        else
          echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源3: 华为云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从华为云镜像下载..."
        if curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从华为云镜像下载成功"
        else
          echo "❌ 华为云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源4: 官方源
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从官方源下载..."
        if curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从官方源下载成功"
        else
          echo "❌ 官方源下载失败"
        fi
      fi
      
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "true" ]]; then
        echo "正在解压并安装 Docker 二进制包..."
        sudo tar -xzf /tmp/docker.tgz -C /usr/bin --strip-components=1
        sudo chmod +x /usr/bin/docker*
        
        # 创建 systemd 服务文件
        sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service time-set.target
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

        # 创建 docker.socket 文件
        sudo tee /etc/systemd/system/docker.socket > /dev/null <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

        # 创建 docker 用户组
        sudo groupadd docker 2>/dev/null || true
        
        echo "✅ Docker 二进制安装成功"
      else
        echo "❌ 所有下载源都失败，无法安装 Docker"
        echo "请检查网络连接或手动安装 Docker"
        exit 1
      在
生产
      fi
    fi
  在
 fi
  
  sudo systemctl enable docker
  sudo systemctl start docker
  
  echo ">>> [3.5/8] 安装 Docker Compose..."
  # 检查是否已通过插件安装
  if command -v docker compose version &> /dev/null 2>&1; then
    echo "✅ Docker Compose (插件版本) 已安装"
  else
    # 安装独立版本的 docker-compose，使用多个备用下载源
    echo "正在下载 Docker Compose 独立版本..."
    
    # 尝试多个下载源
    DOCKER_COMPOSE_DOWNLOADED=false
    
    # 源1: 阿里云镜像
    echo "尝试从阿里云镜像下载..."
    if sudo curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从阿里云镜像下载成功"
    else
      echo "❌ 阿里云镜像下载失败，尝试下一个源..."
    fi
    
    # 源2: 腾讯云镜像
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从腾讯云镜像下载..."
      if sudo curl -L "https://mirrors.cloud.tencent.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从腾讯云镜像下载成功"
      else
        echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
      fi
    fi
    
    # 源3: 华为云镜像
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从华为云镜像下载..."
      if sudo curl -L "https://mirrors.huaweicloud.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从华为云镜像下载成功"
      else
        echo "❌ 华为云镜像下载失败，尝试下一个源..."
      fi
    fi
    
    # 源4: 中科大镜像
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从中科大镜像下载..."
      if sudo curl -L "https://mirrors.ustc.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从中科大镜像下载成功"
      else
        echo "❌ 中科大镜像下载失败，尝试下一个源..."
      fi
    fi
    
    # 源5: 清华大学镜像
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从清华大学镜像下载..."
      if sudo curl -L "https://mirrors.tuna.tsinghua.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从清华大学镜像下载成功"
      else
        echo "❌ 清华大学镜像下载失败，尝试下一个源..."
      fi
    fi
    
    # 源6: 网易镜像
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从网易镜像下载..."
      if sudo curl -L "https://mirrors.163.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从网易镜像下载成功"
      else
        echo "❌ 网易镜像下载失败，尝试下一个源..."
      fi
    fi
    
    # 源7: 最后尝试 GitHub (如果网络允许)
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
      echo "尝试从 GitHub 下载..."
      if sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
        DOCKER_COMPOSE_DOWNLOADED=true
        echo "✅ 从 GitHub 下载成功"
      else
        echo "❌ GitHub 下载失败"
      fi
    fi
    
    if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "true" ]]; then
      # 设置执行权限
      sudo chmod +x /usr/local/bin/docker-compose
      
      # 创建软链接到 PATH 目录
      sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
      
      echo "✅ Docker Compose 独立版本安装完成"
    else
      echo "⚠️  Docker Compose 独立版本安装失败"
      echo "您仍可以使用 'docker compose' 命令（如果插件已安装）"
    fi
  fi

elif [[ "$OS" == "rocky" ]]; then
  # Rocky Linux 9 使用 dnf 而不是 yum
  sudo dnf install -y dnf-utils
  
  # 尝试多个国内镜像源
  echo "正在配置 Docker 源..."
  DOCKER_REPO_ADDED=false
  
  # 创建Docker仓库配置文件，使用 Rocky Linux 9 兼容的版本
  echo "正在创建 Docker 仓库配置..."
  
  # 源1: 阿里云镜像
  echo "尝试配置阿里云 Docker 源..."
  sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.aliyun.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.aliyun.com/docker-ce/linux/centos/gpg
EOF
  
  if sudo dnf makecache; then
    DOCKER_REPO_ADDED=true
    echo "✅ 阿里云 Docker 源配置成功"
  else
    echo "❌ 阿里云 Docker 源配置失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置腾讯云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.cloud.tencent.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 腾讯云 Docker 源配置成功"
    else
      echo "❌ 腾讯云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置华为云 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.huaweicloud.com/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.huaweicloud.com/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 华为云 Docker 源配置成功"
    else
      echo "❌ 华为云 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置中科大 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.ustc.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 中科大 Docker 源配置成功"
    else
      echo "❌ 中科大 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "尝试配置清华大学 Docker 源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 清华大学 Docker 源配置成功"
    else
      echo "❌ 清华大学 Docker 源配置失败，尝试下一个源..."
    fi
  fi
  
  # 如果所有国内源都失败，尝试官方源
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "所有国内源都失败，尝试官方源..."
    sudo tee /etc/yum.repos.d/docker-ce.repo > /dev/null <<EOF
[docker-ce-stable]
name=Docker CE Stable - \$basearch
baseurl=https://download.docker.com/linux/centos/9/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://download.docker.com/linux/centos/gpg
EOF
    
    if sudo dnf makecache; then
      DOCKER_REPO_ADDED=true
      echo "✅ 官方 Docker 源配置成功"
    else
      echo "❌ 官方 Docker 源也配置失败"
    fi
  fi
  
  if [[ "$DOCKER_REPO_ADDED" == "false" ]]; then
    echo "❌ 所有 Docker 源都配置失败，无法继续安装"
    echo "请检查网络连接或手动配置 Docker 源"
    exit 1
  fi

  echo ">>> [3/8] 安装 Docker CE 最新版..."
  
  # 临时禁用 set -e，允许错误处理
  set +e
  
  echo "正在尝试安装 Docker CE（这可能需要几分钟，请耐心等待）..."
  echo "如果安装过程卡住，可能是网络问题或依赖解析中，请等待..."
  
  # 尝试安装 Docker，使用超时机制（30分钟超时）
  INSTALL_OUTPUT=""
  INSTALL_STATUS=1
  
  # 使用 timeout 命令（如果可用）或直接执行
  # 注意：使用 bash -c 确保 sudo 函数在子 shell 中可用
  if command -v timeout &> /dev/null; then
    INSTALL_OUTPUT=$(timeout 1800 bash -c "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin" 2>&1)
    INSTALL_STATUS=$?
    if [[ $INSTALL_STATUS -eq 124 ]]; then
      echo "❌ 安装超时（30分钟），可能是网络问题或依赖解析失败"
      INSTALL_STATUS=1
    fi
  else
    INSTALL_OUTPUT=$(sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin 2>&1)
    INSTALL_STATUS=$?
  fi
  
  # 重新启用 set -e
  set -e
  
  if [[ $INSTALL_STATUS -eq 0 ]]; then
    echo "✅ Docker CE 安装成功"
  else
    # 显示详细错误信息
    echo ""
    echo "❌ Docker CE 批量安装失败"
    echo "错误详情："
    echo "$INSTALL_OUTPUT" | tail -20
    echo ""
    
    # 检查错误类型
    if echo "$INSTALL_OUTPUT" | grep -qiE "(timeout|timed out|connection|网络|network)"; then
      echo "⚠️  检测到可能的网络问题，请检查网络连接"
    fi
    if echo "$INSTALL_OUTPUT" | grep -qiE "(repo|repository|仓库|not found|找不到)"; then
      echo "⚠️  检测到可能的仓库配置问题，请检查 Docker 源配置"
    fi
    
    echo "正在尝试逐个安装组件..."
    
    # 临时禁用 set -e
    set +e
    
    # 逐个安装组件
    echo "  - 正在安装 containerd.io..."
    CONTAINERD_OUTPUT=$(sudo dnf install -y containerd.io 2>&1)
    CONTAINERD_STATUS=$?
    if [[ $CONTAINERD_STATUS -eq 0 ]]; then
      echo "  ✅ containerd.io 安装成功"
    else
      echo "  ❌ containerd.io 安装失败"
      echo "  错误信息: $(echo "$CONTAINERD_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-ce-cli..."
    DOCKER_CLI_OUTPUT=$(sudo dnf install -y docker-ce-cli 2>&1)
    DOCKER_CLI_STATUS=$?
    if [[ $DOCKER_CLI_STATUS -eq 0 ]]; then
      echo "  ✅ docker-ce-cli 安装成功"
    else
      echo "  ❌ docker-ce-cli 安装失败"
      echo "  错误信息: $(echo "$DOCKER_CLI_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-ce..."
    DOCKER_CE_OUTPUT=$(sudo dnf install -y docker-ce 2>&1)
    DOCKER_CE_STATUS=$?
    if [[ $DOCKER_CE_STATUS -eq 0 ]]; then
      echo "  ✅ docker-ce 安装成功"
    else
      echo "  ❌ docker-ce 安装失败"
      echo "  错误信息: $(echo "$DOCKER_CE_OUTPUT" | tail -5)"
    fi
    
    echo "  - 正在安装 docker-buildx-plugin..."
    BUILDX_OUTPUT=$(sudo dnf install -y docker-buildx-plugin 2>&1)
    BUILDX_STATUS=$?
    if [[ $BUILDX_STATUS -eq 0 ]]; then
      echo "  ✅ docker-buildx-plugin 安装成功"
    else
      echo "  ⚠️  docker-buildx-plugin 安装失败（可选组件，不影响核心功能）"
    fi
    
    # 重新启用 set -e
    set -e
    
    # 检查是否至少安装了核心组件
    if ! command -v docker &> /dev/null; then
      echo ""
      echo "❌ 包管理器安装完全失败，尝试二进制安装..."
      
      # 二进制安装备选方案
      echo "正在下载 Docker 二进制包..."
      
      # 尝试多个下载源
      DOCKER_BINARY_DOWNLOADED=false
      
      # 源1: 阿里云镜像
      echo "尝试从阿里云镜像下载 Docker 二进制包..."
      if curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
        DOCKER_BINARY_DOWNLOADED=true
        echo "✅ 从阿里云镜像下载成功"
      else
        echo "❌ 阿里云镜像下载失败，尝试下一个源..."
      fi
      
      # 源2: 腾讯云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从腾讯云镜像下载..."
        if curl -fsSL https://mirrors.cloud.tencent.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从腾讯云镜像下载成功"
        else
          echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源3: 华为云镜像
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从华为云镜像下载..."
        if curl -fsSL https://mirrors.huaweicloud.com/docker-ce/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从华为云镜像下载成功"
        else
          echo "❌ 华为云镜像下载失败，尝试下一个源..."
        fi
      fi
      
      # 源4: 官方源
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "false" ]]; then
        echo "尝试从官方源下载..."
        if curl -fsSL https://download.docker.com/linux/static/stable/${DOCKER_ARCH}/docker-20.10.24.tgz -o /tmp/docker.tgz --connect-timeout 10 --max-time 60; then
          DOCKER_BINARY_DOWNLOADED=true
          echo "✅ 从官方源下载成功"
        else
          echo "❌ 官方源下载失败"
        fi
      fi
      
      if [[ "$DOCKER_BINARY_DOWNLOADED" == "true" ]]; then
        echo "正在解压并安装 Docker 二进制包..."
        sudo tar -xzf /tmp/docker.tgz -C /usr/bin --strip-components=1
        sudo chmod +x /usr/bin/docker*
        
        # 创建 systemd 服务文件
        sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service time-set.target
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/dockerd -H fd://
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always
StartLimitBurst=3
StartLimitInterval=60s
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity
Delegate=yes
KillMode=process
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
EOF

        # 创建 docker.socket 文件
        sudo tee /etc/systemd/system/docker.socket > /dev/null <<EOF
[Unit]
Description=Docker Socket for the API

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

        # 创建 docker 用户组
        sudo groupadd docker 2>/dev/null || true
        
        echo "✅ Docker 二进制安装成功"
      else
        echo "❌ 所有下载源都失败，无法安装 Docker"
        echo "请检查网络连接或手动安装 Docker"
        exit 1
      fi
    fi
  fi
  
  sudo systemctl enable docker
  sudo systemctl start docker
  
  echo ">>> [3.5/8] 安装 Docker Compose..."
  # 安装最新版本的 docker-compose，使用多个备用下载源
  echo "正在下载 Docker Compose..."
  
  # 尝试多个下载源
  DOCKER_COMPOSE_DOWNLOADED=false
  
  # 源1: 阿里云镜像
  echo "尝试从阿里云镜像下载..."
  if sudo curl -L "https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
    DOCKER_COMPOSE_DOWNLOADED=true
    echo "✅ 从阿里云镜像下载成功"
  else
    echo "❌ 阿里云镜像下载失败，尝试下一个源..."
  fi
  
  # 源2: 腾讯云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从腾讯云镜像下载..."
    if sudo curl -L "https://mirrors.cloud.tencent.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从腾讯云镜像下载成功"
    else
      echo "❌ 腾讯云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源3: 华为云镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从华为云镜像下载..."
    if sudo curl -L "https://mirrors.huaweicloud.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从华为云镜像下载成功"
    else
      echo "❌ 华为云镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源4: 中科大镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从中科大镜像下载..."
    if sudo curl -L "https://mirrors.ustc.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从中科大镜像下载成功"
    else
      echo "❌ 中科大镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源5: 清华大学镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从清华大学镜像下载..."
    if sudo curl -L "https://mirrors.tuna.tsinghua.edu.cn/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从清华大学镜像下载成功"
    else
      echo "❌ 清华大学镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源6: 网易镜像
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从网易镜像下载..."
    if sudo curl -L "https://mirrors.163.com/docker-toolbox/linux/compose/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从网易镜像下载成功"
    else
      echo "❌ 网易镜像下载失败，尝试下一个源..."
    fi
  fi
  
  # 源7: 最后尝试 GitHub (如果网络允许)
  # 源7: 最后尝试 GitHub (如果网络允许)
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "尝试从 GitHub 下载..."
    if sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose --connect-timeout 10 --max-time 30; then
      DOCKER_COMPOSE_DOWNLOADED=true
      echo "✅ 从 GitHub 下载成功"
    else
      echo "❌ GitHub 下载失败"
    fi
  fi
  
  # 检查是否下载成功
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "false" ]]; then
    echo "❌ 所有下载源都失败了，尝试使用包管理器安装..."
    
    # 使用包管理器作为备选方案
    if sudo dnf install -y docker-compose-plugin; then
      echo "✅ 通过包管理器安装 docker-compose-plugin 成功"
      DOCKER_COMPOSE_DOWNLOADED=true
    else
      echo "❌ 包管理器安装也失败了"
    fi
  fi
  
  if [[ "$DOCKER_COMPOSE_DOWNLOADED" == "true" ]]; then
    # 设置执行权限
    sudo chmod +x /usr/local/bin/docker-compose
    
    # 创建软链接到 PATH 目录
    sudo ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose
    
    echo "✅ Docker Compose 安装完成"
  else
    echo "❌ Docker Compose 安装失败，请手动安装"
    echo "建议访问: https://docs.docker.com/compose/install/ 查看手动安装方法"
  fi
else
  echo "暂不支持该系统: $OS"
  exit 1
fi

echo ">>> [5/8] 配置国内镜像..."

# 循环等待用户选择镜像版本
while true; do
    echo "请选择版本:"
    echo "1) 轩辕镜像免费版 (专属域名: docker.xuanyuan.me)"
    echo "2) 轩辕镜像专业版 (专属域名: 专属域名 + docker.xuanyuan.me)"
    read -p "请输入选择 [1/2]: " choice
    
    if [[ "$choice" == "1" || "$choice" == "2" ]]; then
        break
    else
        echo "❌ 无效选择，请输入 1 或 2"
        echo ""
    fi
done

mirror_list=""

if [[ "$choice" == "2" ]]; then
  read -p "请输入您的轩辕镜像专属域名 (访问官网获取：https://xuanyuan.cloud): " custom_domain

  # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
  if [[ "$custom_domain" == *.xuanyuan.run ]]; then
    custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
    mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://$custom_domain_dev",
  "https://docker.xuanyuan.me"
]
EOF
)
  else
    mirror_list=$(cat <<EOF
[
  "https://$custom_domain",
  "https://docker.xuanyuan.me"
]
EOF
)
  fi
else
  mirror_list=$(cat <<EOF
[
  "https://docker.xuanyuan.me"
]
EOF
)
fi

sudo mkdir -p /etc/docker

# 根据用户选择设置 insecure-registries
if [[ "$choice" == "2" ]]; then
  # 清理用户输入的域名，移除协议前缀
  custom_domain=$(echo "$custom_domain" | sed 's|^https\?://||')
  
  # 检查是否输入的是 .run 地址，如果是则自动添加 .dev 地址
  if [[ "$custom_domain" == *.xuanyuan.run ]]; then
    custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
    insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "$custom_domain_dev",
  "docker.xuanyuan.me"
]
EOF
)
  else
    insecure_registries=$(cat <<EOF
[
  "$custom_domain",
  "docker.xuanyuan.me"
]
EOF
)
  fi
else
  # 默认不配置 insecure-registries 以提高安全性，除非用户明确需要
  # 或者仅配置 docker.xuanyuan.me 作为必要的加速端点
  insecure_registries=$(cat <<EOF
[
  "docker.xuanyuan.me"
]
EOF
)
fi

# 准备 DNS 配置字符串
dns_config=""
if [[ "$SKIP_DNS" != "true" ]]; then
  if ! grep -q "nameserver" /etc/resolv.conf; then
     dns_config=',
  "dns": ["119.29.29.29", "114.114.114.114"]'
  else
     echo "ℹ️  检测到系统已配置 DNS，跳过 Docker DNS 配置以避免冲突"
  fi
fi

cat <<EOF | sudo tee /etc/docker/daemon.json > /dev/null
{
  "registry-mirrors": $mirror_list,
  "insecure-registries": $insecure_registries$dns_config
}
EOF

sudo systemctl daemon-reexec || true
sudo systemctl restart docker || true

echo ">>> [6/8] 安装完成！"
echo "🎉Docker 镜像已配置完成"
echo "轩辕镜像 · 专业版 - 开发者首选的专业 Docker 镜像高效稳定拉取服务"
echo "官方网站: https://xuanyuan.cloud/"

echo ">>> [7/8] 重载 Docker 配置并重启服务..."
sudo systemctl daemon-reexec || true
sudo systemctl restart docker || true

# 等待 Docker 服务完全启动
echo "等待 Docker 服务启动..."
sleep 3

# 验证 Docker 服务状态
if systemctl is-active --quiet docker; then
    echo "✅ Docker 服务已成功启动"
    echo "✅ 镜像配置已生效"
    
    # 显示当前配置的镜像源
    echo "当前配置的镜像源:"
    if [[ "$choice" == "2" ]]; then
        echo "  - https://$custom_domain (优先)"
        if [[ "$custom_domain" == *.xuanyuan.run ]]; then
            custom_domain_dev="${custom_domain%.xuanyuan.run}.xuanyuan.dev"
            echo "  - https://$custom_domain_dev (备用)"
        fi
        echo "  - https://docker.xuanyuan.me (备用)"
    else
        echo "  - https://docker.xuanyuan.me"
    fi
    
    echo ""
    echo "🎉 安装和配置完成！"
    echo ""
    
    # 将执行脚本的用户添加到 docker 组
    echo ">>> [8/8] 配置用户权限..."
    
    # 定义函数：安全地添加用户到 docker 组
    add_user_to_docker_group() {
        local target_user="$1"
        if ! groups "$target_user" | grep -q "\bdocker\b"; then
            echo "⚠️  注意：将用户 $target_user 加入 docker 组意味着赋予该用户 root 级权限。"
            echo "⚠️  这可能会带来安全风险。如果您不确定，请选择 'n'。"
            read -p "是否继续将 $target_user 添加到 docker 组？[Y/n] " confirm_add_group
            confirm_add_group=${confirm_add_group:-Y}
            
            if [[ "$confirm_add_group" =~ ^[Yy]$ ]]; then
                sudo usermod -aG docker "$target_user" 2>/dev/null || true
                echo "✅ 已将用户 $target_user 添加到 docker 组"
                echo "⚠️  请重新登录或执行 'newgrp docker' 使权限生效"
            else
                echo "ℹ️  已跳过用户组配置"
            fi
        else
            echo "✅ 用户 $target_user 已在 docker 组中"
        fi
    }

    if [ -n "$SUDO_USER" ]; then
        # 如果通过 sudo 执行
        add_user_to_docker_group "$SUDO_USER"
    elif [ "$(id -u)" -ne 0 ]; then
        # 如果直接以非 root 用户执行
        add_user_to_docker_group "$USER"
    else
        # 如果已经是 root 用户，提示信息
        echo "ℹ️  当前以 root 用户执行，无需添加到 docker 组"
    fi
    
    echo ""
    echo "轩辕镜像 · 专业版 - 开发者首选的专业 Docker 镜像高效稳定拉取服务"
    echo "官方网站: https://xuanyuan.cloud/"

    # ==========================
    # BEGIN: 新增的 Docker 验证步骤
    # ==========================
    echo "=========================================="
    echo "✅ Docker 安装与配置验证开始"
    echo "=========================================="
    
    echo ">>> 正在检查 Docker 版本..."
    if command -v docker &> /dev/null; then
        sudo docker version --format '{{.Server.Version}} (Engine) | {{.Client.Version}} (Client)' || true
        echo "✅ Docker 版本信息显示成功。"
    else
        echo "❌ Docker 命令未找到，无法获取版本信息。"
    fi

    echo ""
    echo ">>> 正在尝试拉取并运行 'hello-world' 镜像..."
    if command -v docker &> /dev/null; then
        # 注意：这里继续使用 sudo，因为当前非root用户可能尚未重新登录获取docker组权限
        if sudo docker run hello-world; then
            echo "✅ 'hello-world' 镜像拉取并运行成功！"
        else
            echo "❌ 'hello-world' 镜像拉取或运行失败。"
            echo "ℹ️  这可能是由于网络问题、镜像源配置问题或 Docker 服务未完全准备好。"
            echo "ℹ️  请尝试手动执行 'sudo docker run hello-world' 或检查日志。"
        fi
    else
        echo "❌ Docker 命令未找到，无法运行测试镜像。"
    fi
    
    echo "=========================================="
    echo "✅ Docker 验证步骤完成。"
    echo "=================================================="
    # END: 新增的 Docker 验证步骤

else
    echo "❌ Docker 服务启动失败，请检查配置"
    exit 1
fi
