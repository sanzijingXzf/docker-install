# docker-install
docker一键安装脚本说明

源代码参考：https://xuanyuan.cloud/docker.sh


**操作步骤：**

1.  **下载脚本到本地文件：**
    打开你的服务器终端，执行以下命令将脚本下载到当前目录，并命名为 `docker_install.sh`：

    ```bash
    curl -o docker_install.sh -sSL https://raw.githubusercontent.com/sanzijingXzf/docker-install/refs/heads/main/docker.sh
    ```

    *   这会将脚本内容下载到 `docker_install.sh` 文件中。

2.  **赋予脚本执行权限：**
    为了让脚本能够运行，你需要给它添加可执行权限：

    ```bash
    chmod +x docker_install.sh
    ```

3.  **运行脚本并进行交互：**
    现在，使用 `sudo bash` 命令运行脚本，这将确保脚本以 `bash` 解释器执行（避免 `export -f` 错误）并拥有必要的 `root` 权限：

    ```bash
    sudo bash ./docker_install.sh
    ```

    脚本运行后，你将看到一系列交互式提示，请根据你的需求进行选择：

    *   **欢迎界面和操作模式选择：**
        ```
        ==========================================
        🐳 欢迎使用轩辕镜像 Docker 一键安装配置脚本
        ==========================================
        官方网站: https://xuanyuan.cloud/

        请选择操作模式：
        1) 一键安装配置（推荐）
        2) 修改轩辕镜像专属域名

        请输入选择 [1/2]:
        ```
        **请在这里输入 `1` 并按回车，选择 "一键安装配置"（推荐）。**

    *   **检测到 Docker 已安装（如果之前有安装）：**
        如果你的系统已经安装了 Docker，脚本会检测到并提示你是否继续安装/升级。
        ```
        ⚠️ 检测到系统已安装 Docker 版本: X.XX.X
        ...
        请确认是否继续：
        1) 确认继续安装/升级 Docker
        2) 返回选择菜单
        请输入选择 [1/2]:
        ```
        **请在这里输入 `1` 并按回车，确认继续安装/升级。**

    *   **轩辕镜像版本选择：**
        在 Docker 安装或升级完成后，脚本会提示你配置轩辕镜像。
        ```
        请选择版本：
        1) 轩辕镜像免费版 (专属域名: docker.xuanyuan.me)
        2) 轩辕镜像专业版 (专属域名: 专属域名 + docker.xuanyuan.me)
        请输入选择 [1/2]:
        ```
        **请在这里输入 `1` 并按回车，选择“轩辕镜像免费版”。**
        (如果你有专业版专属域名，则输入 `2` 并按照提示输入你的域名。)

    *   **其他安装和配置过程：**
        脚本会继续自动配置 Docker 源、安装 Docker CE、安装 Docker Compose，并重启 Docker 服务。这期间可能会有较多的输出，请耐心等待。

    *   **将当前用户添加到 Docker 组 (重要！)：**
        安装接近尾声时，脚本会询问是否将当前用户添加到 `docker` 用户组，这样你可以不使用 `sudo` 命令来运行 Docker。
        ```
        是否继续将 yourusername 添加到 docker 组？[Y/n]
        ```
        **建议输入 `Y` 并按回车（`Y` 是默认选项），以便后续方便使用 Docker。**

4.  **自动 Docker 验证结果：**
    脚本执行完毕后，你将看到新增的 Docker 验证步骤输出，包括 Docker 版本信息和 `hello-world` 镜像的运行结果：

    ```
    ==========================================
    ✅ Docker 安装与配置验证开始
    ==========================================

    >>> 正在检查 Docker 版本...
    XX.XX.X (Engine) | XX.XX.X (Client)
    ✅ Docker 版本信息显示成功。

    >>> 正在尝试拉取并运行 'hello-world' 镜像...

    Hello from Docker!
    This message shows that your installation appears to be working correctly.
    ...
    ✅ 'hello-world' 镜像拉取并运行成功！
    ==========================================
    ✅ Docker 验证步骤完成。
    ==================================================
    ```

5.  **使 Docker 权限生效 (重新登录或 `newgrp docker`)：**
    **这是非常关键的一步！** 即使 Docker 已安装并运行成功，如果你选择了将用户添加到 `docker` 组，你仍然需要 **重新登录你的终端会话** (比如关闭 SSH 连接再重新连入) 或者在当前终端执行 `newgrp docker` 命令，才能让新的权限生效，即不带 `sudo` 也能运行 `docker` 命令。

    ```bash
    # 如果你不想重新登录，可以在当前会话中执行此命令
    newgrp docker
    ```

6.  **最终验证 (重新登录后)：**
    重新登录终端后，你可以再次运行以下命令进行验证，此时应该无需 `sudo`：

    ```bash
    docker version
    docker run hello-world
    ```
