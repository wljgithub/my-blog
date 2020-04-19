#! /bin/bash

# Notice: this script only support centos 6 now
# And It is recommended that to run this script on a pure machine instance,to prevent unpredictable error

# export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
# set -ex
set -e

# Blog login config
# used to login blog on browser
BLOG_ACCOUNT="admin"
BLOG_PASSWORD="adminpassword"
SALT=')(*&^'

# Blog deploy config
BLOG_REPO='https://github.com/wljgithub/my-blog.git'
BLOG_NAME='my-blog'
BLOG_ROOT_PATH="${HOME}/${BLOG_NAME}"
BLOG_CONFIG_FILE="${BLOG_ROOT_PATH}/conf/config.yml"

# Mysql config
MYSQL_USER="root"
MYSQL_ROOT_PASSWORD='root-password'
MYSQL_INIT_FILE="/var/mysql/init"

# Nginx web static dir
WEBSITE_ROOT_DIR='/data'
WEBSITE_STATIC_DIR="${WEBSITE_ROOT_DIR}/www"
WEBSITE_STATIC_DIR_BACKUP="${WEBSITE_ROOT_DIR}/backup"

# shell config
NGINX_USER="nginx"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"
GO_PROXY='https://goproxy.cn'
SHELL_CONFIG_FILE="/etc/profile.d/myconfig.sh"

IP=""
NETWORK_PORTS=(
    "80"
    "443")

DEPENDENCIES=(
    "git"
    "wget"
    "epel-release"
    "curl"
    "yum-utils"
)
RPM_REPOS=(
    "https://dl.yarnpkg.com/rpm/yarn.repo"                                                       #yarn repo
    "https://dev.mysql.com/get/mysql80-community-release-el6-3.noarch.rpm"                       # mysql repo
    "http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm" #nginx repo
)

none=$(printf '\e[0m')
green=$(printf '\e[92m')
# blue=$(printf '\e[0;34m')
yellow=$(printf '\e[0;33m')

init() {
    check_run_privilege
    check_distrs
    ask_user_config
    check_dependency
}

check_run_privilege() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "This script must be run as root"
    fi
}

check_distrs() {
    local version=$(rpm --eval %{centos_ver})
    if [[ ${version} -ne 6 ]]; then
        error_exit "This script only suport centos6 now"
    fi
}
check_dependency() {
    update_package_manager
    for dependency in "${DEPENDENCIES[@]}"; do
        check_command_exist ${dependency} || install_dependency ${dependency}
    done
}
deploy_env() {
    install_rpm_repo

    check_command_exist "yarn" || install_yarn

    if ! check_command_exist "mysql"; then
        install_mysql && config_mysql
    else
        config_mysql
    fi

    if ! check_command_exist "go"; then
        install_golang
    fi
    config_shell_variables
    if ! check_command_exist "nginx"; then
        install_nginx && config_nginx
    else
        config_nginx
    fi

}
install_rpm_repo() {
    for REPO in "${RPM_REPOS[@]}"; do
        if [[ "${REPO}" =~ .rpm$ ]]; then
            yum localinstall -y "${REPO}"
        elif [[ "${REPO}" =~ .repo$ ]]; then
            yum-config-manager --add-repo "${REPO}"
        fi
    done

}
install_golang() {
    install_dependency "golang"

}
config_shell_variables() {
    cat >${SHELL_CONFIG_FILE} <<-EOF
GOPATH=$HOME/.go
GOBIN=${GOPATH}/bin

GO111MODULE=on
GOPROXY=https://goproxy.cn

GIN_MODE=release
VUE_APP_PROJECT_ENV="production"

PATH=${PATH}:${GOBIN}
PATH="$(yarn global bin):$PATH"
export PATH GO111MODULE GOPROXY GIN_MODE GOBIN VUE_APP_PROJECT_ENV GOPATH
EOF
    source "${SHELL_CONFIG_FILE}"
}

install_mysql() {
    install_dependency --enablerepo=mysql80-community install mysql-community-server
}

enable_mysql() {
    /sbin/chkconfig --levels 235 mysqld on
}

restart_mysql() {
    stop_mysql
    start_mysql
}

start_mysql() {
    if [[ ! -f ${MYSQL_INIT_FILE} ]]; then
        error_exit "can't find mysql init file"
    fi
    mysqld --init-file=${MYSQL_INIT_FILE} --console --user=mysql &
    until pidof mysqld; do
        echo -e "waitting for mysqld start...."
    done
    echo -e "mysql has successfuly started"
}
stop_mysql() {
    local mysqlPID="$(pgrep mysql)"
    if [[ -n ${mysqlPID} ]]; then
        kill ${mysqlPID}
    fi
    echo -e "mysql has successfuly stop"
}
config_mysql() {
    init_mysql_data_dir
    # this is a mysql offical shell script,used to remove anonymous users and remove test datebases
    # mysql_secure_installation || error_exit "failed to config mysql"

    reset_mysql_password || error_exit "failed to reset mysql root password"
    enable_mysql
}
init_mysql_data_dir() {
    mysqlDir="/var/lib/mysql/"
    if [[ -d "${mysqlDir}" ]]; then
        rm -rf "${mysqlDir}"
        # mysqld --initialize --user=mysql
        service mysqld restart && service mysqld stop
        # chmod -R 755 "${mysqlDir}"
    fi

}
set_blog_password() {
    local password
    password=$(echo -n "${BLOG_PASSWORD}${SALT}" | md5sum | awk '{print $1}')
    DATE=$(date '+%Y-%m-%d')

    cat <<-EOF | mysql -u root -p${MYSQL_ROOT_PASSWORD}
INSERT INTO blog.auth (created_time, account, password) VALUES ("${DATE}","${BLOG_ACCOUNT}" , "${password}");
EOF
}

reset_mysql_password() {
    create_mysql_init_file
    restart_mysql
}
create_mysql_init_file() {
    mkdir -p $(dirname "${MYSQL_INIT_FILE}")
    cat >"${MYSQL_INIT_FILE}" <<-EOF
SET GLOBAL validate_password.length = 4 ;
SET GLOBAL validate_password.number_count = 0;
SET GLOBAL  validate_password.policy = LOW;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
EOF
    chown -R mysql:mysql $(dirname "${MYSQL_INIT_FILE}")
    chmod 755 "${MYSQL_INIT_FILE}"
}
create_mysql_table() {
    if [[ -f "${BLOG_ROOT_PATH}/db.sql" ]]; then
        # cat "${BLOG_ROOT_PATH}/db.sql" | mysql -u root "-p${MYSQL_ROOT_PASSWORD}" || echo "failed to create blog mysql tables"
        mysql -u root -p${MYSQL_ROOT_PASSWORD} <"${BLOG_ROOT_PATH}/db.sql" || echo "failed to create blog mysql tables"
    else
        echo "can't find init file to create datebase"
    fi
    set_blog_password || echo -e "failed to set blog password in mysql"

}
install_nodejs() {
    curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash - || error_exit "failed to install nodejs"
    install_dependency "nodejs"
}
install_yarn() {
    if ! check_command_exist "node"; then
        install_nodejs
    fi
    # curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo || error_exit "failed to install yarn"
    # yum localinstall -y https://dl.yarnpkg.com/rpm/yarn.repo
    install_dependency "yarn"
}

run_blog() {
    compile_frontend
    prepare_static_dir
    copy_static_to_nginx
    chdir_mode
    compile_backend
    run_server
}

clone_repo() {
    cd ${HOME}
    git clone "${BLOG_REPO}" "${BLOG_NAME}" || cd "${HOME}/${BLOG_NAME}"
}

compile_frontend() {
    # that's so embarrassing,my machine memory is only 1 Gb.
    # so for successfuly to compile frontend,i need to shutdown mysql
    stop_mysql || echo
    cd "${BLOG_ROOT_PATH}/front-end"
    yarn install && yarn build
    restart_mysql
}
prepare_static_dir() {
    # if folder already exist, mv all the file to backup folder
    if [[ -d "${WEBSITE_STATIC_DIR}" ]]; then
        if [[ -d "${WEBSITE_STATIC_DIR_BACKUP}" ]]; then
            rm -rf "${WEBSITE_STATIC_DIR_BACKUP}"
        fi
        mkdir -p "${WEBSITE_STATIC_DIR_BACKUP}" && chown -R ${NGINX_USER}:${NGINX_USER} "${WEBSITE_STATIC_DIR_BACKUP}"
        mv ${WEBSITE_STATIC_DIR}/* "${WEBSITE_STATIC_DIR_BACKUP}"
    fi
    make_website_dir
}

copy_static_to_nginx() {
    cp -a ${BLOG_ROOT_PATH}/front-end/dist/* "${WEBSITE_STATIC_DIR}"
}

compile_backend() {
    cd "${BLOG_ROOT_PATH}" && go build
}

run_server() {
    [[ -n "$(pgrep ${BLOG_NAME})" ]] && pkill "${BLOG_NAME}"
    cd "${BLOG_ROOT_PATH}" && ./${BLOG_NAME} &
}

install_dependency() {
    yum install -y "$@" || exit 1
}

update_package_manager() {
    yum update -y
}
check_command_exist() {
    # POSIX Compatible
    command -v $1 &>/dev/null
}
error_exit() {
    echo -e "$@" && exit 1
}
open_port_in_firewall() {
    # centos6
    for PORT in "${NETWORK_PORTS[@]}"; do
        check_network_rule "${PORT}" || add_network_rule "${PORT}"
    done
    service iptables save && service iptables reload
}
add_network_rule() {
    iptables -C INPUT -p tcp --dport "${1}" --jump ACCEPT
}
check_network_rule() {
    iptables -I INPUT -p tcp --dport "${1}" -j ACCEPT
}

install_nginx() {
    # wget http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    # rpm -ivh nginx-release-centos-6-0.el6.ngx.noarch.rpm
    install_dependency "nginx"
}
config_nginx() {
    cat >"${NGINX_CONFIG_FILE}" <<-EOF

user  root;
worker_processes  1;

error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}


http {
 server {
          server_name xiulu.xyz;
          location / {
                root /data/www;
        }
          location /api {

            # Simple requests
            if (\$request_method ~* "(GET|POST)") {
              add_header "Access-Control-Allow-Origin"  *;
            }

            # Preflighted requests
            if (\$request_method = OPTIONS ) {
              add_header "Access-Control-Allow-Origin"  *;
              add_header "Access-Control-Allow-Methods" "GET, POST, OPTIONS, HEAD";
              add_header "Access-Control-Allow-Headers" "Authorization, Origin, X-Requested-With, Content-Type, Accept,Blog-Token";
              return 200;
            }
                proxy_pass http://localhost:3000;
          }
        }

    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '\$remote_addr - \$remote_user [\$time_local] "\$request" '
                      '\$status \$body_bytes_sent "\$http_referer" '
                      '"\$http_user_agent" "\$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;
    gzip on;
    gzip_min_length 1k;
    gzip_comp_level 1;
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript ;
    gzip_static on;
    gzip_vary on;
    gzip_buffers 2 4k;
    gzip_http_version 1.1;


    include /etc/nginx/conf.d/*.conf;
}
EOF
    test_nginx_config || error_exit "malformat nginx config"
    reload_nginx
}
reload_nginx() {
    if nginx -s stop; then
        nginx -c "${NGINX_CONFIG_FILE}"
    else
        nginx -c "${NGINX_CONFIG_FILE}"
    fi
}
test_nginx_config() {
    nginx -t
}
config_blog() {
    clone_repo
    create_mysql_table
}

make_website_dir() {
    mkdir -p "${WEBSITE_STATIC_DIR}"
}
chdir_mode() {
    chown -R "${NGINX_USER}:${NGINX_USER}" "${WEBSITE_ROOT_DIR}"
}

ask_user_config() {
    while :; do
        echo -e "Before deploy blog,you need to enter your personal blog config"
        echo

        echo -e "Length of Mysql password need to more than 8 "
        read -r -p "Mysql Root Password (Default: root-password):" password

        if [[ -n "${password}" ]] && [[ "${#password}" -lt 8 ]]; then
            echo -e "Your Mysql password's length is short than 8"
            echo -e "Need to config again"
            continue
        fi
        [[ -n "${password}" ]] && MYSQL_ROOT_PASSWORD=${password}

        read -r -p "Blog Account (Default: admin):" account

        [[ -n "${account}" ]] && BLOG_ACCOUNT=${account}

        read -r -p "Blog Password (Default:adminpassword):" blogPassword
        [[ -n "${blogPassword}" ]] && BLOG_PASSWORD=${blogPassword}

        cat <<-EOF

        Your Config is below:


        Mysql Password: ${MYSQL_ROOT_PASSWORD}

        Blog  Account: ${BLOG_ACCOUNT}
        
        Blog  Password: ${BLOG_PASSWORD}
EOF
        local confirm="y"
        read -r -p "Confirm?(y/n)" confirm

        if [[ -n "${confirm}" ]]; then
            confirm=$(echo ${confirm} || tr '[:upper:]' '[:lower:]')
        fi

        case "${confirm}" in
        "y")
            break
            ;;
        "n")
            continue
            ;;
        *)
            echo "unsupported option" && continue
            ;;
        esac

    done

}

renew_https() {
    echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew -q" | sudo tee -a /etc/crontab >/dev/null
}

update_blog_config() {
    install_yaml_parser
    yq w -i "${BLOG_CONFIG_FILE}" db.user ${MYSQL_USER}
    yq w -i ${BLOG_CONFIG_FILE} db.password ${MYSQL_ROOT_PASSWORD}

}
install_yaml_parser() {
    go get github.com/mikefarah/yq/v3
}
pull_repo() {
    cd "${BLOG_ROOT_PATH}" || error_exit "you haven't clone the blog repo"
    if [[ -n "$(git status --porcelain)" ]]; then
        git add -A && git stash && git stash drop
        # cd "${BLOG_ROOT_PATH}" && git checkout .
    fi
    git pull
}
update_success_prompt() {
    get_ip
    echo -e "Succeed to update blog"
    echo -e "Go ahead and play with it by visit ${IP} on your browser"
    exit
}
update_blog() {
    pull_repo
    run_blog
    update_success_prompt
}
deploy_blog() {
    init
    deploy_env
    open_port_in_firewall
    config_blog
    update_blog_config
    run_blog
    success_prompt
}
manage_blog() {
    clear
    while :; do
        cat <<-EOF
            Manage the following service.

            1.restart mysql     

            2.stop mysql       
            
            3.view nginx log       
EOF

        read -r -p "option:" choose

        case "${choose}" in
        1)
            restart_mysql
            break
            ;;
        2)
            stop_mysql
            break
            ;;
        3)
            tail -f /var/log/nginx/*
            break
            ;;
        *)
            error_choice
            ;;
        esac

    done
}
get_ip() {
    ip=$(curl -s https://ipinfo.io/ip)
    [[ -z "${ip}" ]] && ip=$(curl -s https://api.ip.sb/ip)
    [[ -z "${ip}" ]] && ip=$(curl -s https://api.ipify.org)
    [[ -z "${ip}" ]] && ip=$(curl -s https://ip.seeip.org)
    [[ -z "${ip}" ]] && error_exit "failed to get your machine ip"
    IP="${ip}"
}
success_prompt() {
    get_ip
    clear
    cat <<-EOF
    Congratulation.
    You have successfuly deployed the blog.
    
    Your personal config:

        Mysql User: ${yellow} root ${none}

        Mysql Password: ${yellow} ${MYSQL_ROOT_PASSWORD} ${none}

        Blog  Account: ${yellow} ${BLOG_ACCOUNT} ${none}

        Blog  Password: ${yellow} ${BLOG_PASSWORD} ${none}

    Go ahead and play with it by visit ${green} ${IP} ${none} on you browser.
    By the way,if your are using AWS,don't forget to config security group to allow HTTP request.
EOF
    exit
}
error_choice() {
    echo -e "unsupported optiton,please choose again."
}

clear
while :; do
    cat <<-EOF
            Welcome.
            Select the following options to use this script.

            1.deploy blog       (automatilly to install env such mysql,nginx.and deploy it)

            2.update blog       (just git pull repo,compile codes and update it)
            
            3.manage blog service       (start,stop mysql,nginx etc)
EOF

    read -r -p "option:" choose

    case "${choose}" in
    1)
        deploy_blog
        ;;
    2)
        update_blog
        ;;
    3)
        manage_blog
        ;;
    *)
        error_choice
        ;;
    esac

done
