#! /bin/bash

# Notice: this script only support centos 6 now
# And It is recommended that to run this script on a pure machine instance,to prevent unpredictable error

# export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
# set -ex
set -e

# blog account and password config
BLOG_ACCOUNT="jack"
BLOG_PASSWORD="jack"
SALT=')(*&^'
MYSQL_ROOT_PASSWORD='root-password'
MYSQL_INIT_FILE="${HOME}/.mysql/init"
# website path
BLOG_REPO='https://github.com/wljgithub/my-blog.git'
BLOG_NAME='my-blog'
BLOG_ROOT_PATH="${HOME}/${BLOG_NAME}"
WEBSITE_ROOT_DIR='/data'
WEBSITE_STATIC_DIR="${WEBSITE_ROOT_DIR}/www"

# shell config
NGINX_USER="nginx"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"
GO_PROXY='https://goproxy.cn'
SHELL_CONFIG_FILE="/etc/bashrc"

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

init() {
    check_run_privilege
    check_distrs
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
        install_golang && config_golang
    else
        config_golang
    fi

    if ! check_command_exist "nginx"; then
        install_nginx && config_nginx
    else
        config_nginx
    fi

}

install_golang() {
    install_dependency "golang"

}
config_golang() {
    cat >>${SHELL_CONFIG_FILE} <<-EOF
GOPATH=$HOME/.go
PATH=${PATH}:${GOPATH}/bin
GO111MODULE=on
GOPROXY=${GO_PROXY}
NODE_ENV=production
GIN_MODE=release

export PATH GO111MODULE GOPROXY NODE_ENV GIN_MODE
EOF
    source ${SHELL_CONFIG_FILE}

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
install_mysql() {
    # install_dependency "localinstall" 'https://dev.mysql.com/get/mysql80-community-release-el6-3.noarch.rpm'
    install_dependency --enablerepo=mysql80-community install mysql-community-server
}
enable_mysql() {
    /sbin/chkconfig --levels 235 mysqld on
}

restart_mysql() {
    service mysqld restart
}
start_mysql() {
    service mysqld start
}
stop_mysql() {
    service mysqld stop
}
config_mysql() {
    # this is a mysql offical shell script,used to remove anonymous users and remove test datebases
    # mysql_secure_installation || error_exit "failed to config mysql"

    reset_mysql_password || error_exit "failed to reset mysql root password"
    enable_mysql
}
set_blog_password() {
    BLOG_PASSWORD=$(echo -n "${BLOG_PASSWORD}${SALT}" | md5sum | awk '{print $1}')
    DATE=$(date '+%Y-%m-%d')
    cat <<-EOF | mysql -u root -p${MYSQL_ROOT_PASSWORD}
    INSERT INTO blog.auth (created_time, account, password) VALUES ("${DATE}","${BLOG_ACCOUNT}" , "${BLOG_PASSWORD}");
EOF
}

reset_mysql_password() {
    create_mysql_init_file
    # this is a bug in mysql'lib,need to delete and recreate it
    kill -9 $(pgrep mysql) || echo

    mysqld --init-file=${MYSQL_INIT_FILE} --console --user=mysql

    #     start_mysql && stop_mysql
    #     skip_mysql_auth && sleep 2 && cat | mysql <<-EOF

    # SET GLOBAL validate_password.length = 4 ;
    # SET GLOBAL validate_password.number_count = 0;
    # SET GLOBAL  validate_password.policy = LOW;
    # FLUSH PRIVILEGES;
    # ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'
    # EOF
    rm -rf /var/lib/mysql/
    restart_mysql
}
create_mysql_init_file() {
    mkdir -p $(dirname "${MYSQL_INIT_FILE}")
    cat >"${MYSQL_INIT_FILE}" <<-EOF
UPDATE mysql.user SET authentication_string='${MYSQL_ROOT_PASSWORD}' WHERE user='root' and host='localhost';
EOF
}
create_mysql_table() {
    restart_mysql
    if [[ -f "${BLOG_ROOT_PATH}/db.sql" ]]; then
        cat "${BLOG_ROOT_PATH}/db.sql" | mysql -u root "-p${MYSQL_ROOT_PASSWORD}"
    else
        echo "can't find init file to create datebase"
    fi
    set_blog_password || error_exit "failed to set blog password in mysql"

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

    make_website_dir
    chdir_mode
}
copy_static_to_nginx() {
    cp -a ${BLOG_ROOT_PATH}/front-end/dist/* "${WEBSITE_STATIC_DIR}"
}
compile_backend() {
    cd "${BLOG_ROOT_PATH}" && go build
}
run_server() {
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
        check_network_rule || add_network_rule "${PORT}"
    done
    service iptables save && service iptables reload
}
add_network_rule() {
    iptables -C INPUT -p tcp --dport "${1}" --jump ACCEPT
}
check_network_rule() {
    iptables -I INPUT -p tcp --dport "${1}" -j ACCEPT
}
##manage nginx

# change dir mode
# reload config
#
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

make_website_dir() {
    mkdir -p "${WEBSITE_STATIC_DIR}"
}
chdir_mode() {
    chown -R "${NGINX_USER}:${NGINX_USER}" "${WEBSITE_ROOT_DIR}"
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

#https

renew_https() {
    echo "0 0,12 * * * root python -c 'import random; import time; time.sleep(random.random() * 3600)' && /usr/local/bin/certbot-auto renew -q" | sudo tee -a /etc/crontab >/dev/null
}

pull_repo() {
    cd "${BLOG_ROOT_PATH}" || error_exit "you haven't clone the blog repo"
    if [[ -n "$(git status --porcelain)" ]]; then
        git stash && git stash drop
    fi
    git pull
}

update_blog() {
    pull_repo
    run_blog
}
deploy_blog() {
    init
    deploy_env
    config_blog
    open_port_in_firewall
    run_blog
}
error_choice() {
    echo -e "unsupported optiton,please choose again."
}
# manage_server() {

# }

clear
while :; do
    cat <<-EOF
            Welcome.
            Select the following options to use this script.

            1.deploy blog       (automatilly to install env such mysql,nginx.and deploy it)

            2.update blog       (just git pull repo,compile codes and update it)
EOF

    read -r choose
    case "${choose}" in
    1)
        deploy_blog
        ;;
    2)
        update_blog
        ;;
    *)
        error_choice
        ;;
    esac

done
