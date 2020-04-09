#! /bin/bash

# Notice: this script only support centos 6 now
# And It is recommended that to run this script on a pure machine instance,to prevent unpredictable error

BLOG_REPO='https://github.com/wljgithub/my-blog.git'
BLOG_NAME='my-blog'
BLOG_ROOT_PATH="${HOME}/${BLOG_NAME}"
WEBSITE_ROOT_DIR='/data'
WEBSITE_STATIC_DIR="${WEBSITE_ROOT_DIR}/www"

NGINX_USER="nginx"
NGINX_CONFIG_FILE="/etc/nginx/nginx.conf"
GO_PROXY='https://goproxy.cn'
SHELL_CONFIG_FILE="/etc/bashrc"

BLOG_ACCOUNT="jack"
BLOG_PASSWORD="jack"
SALT=')(*&^'

MYSQL_ROOT_PASSWORD='root-password'

NETWORK_PORTS=(
    "80"
    "3000"
    "443"
)
DEPENDENCIES=(
    "git"
    "wget"
    "epel-release"
    "curl"
)
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]}: '
set -ex

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

    # seems like GOPATH is set by default on go 1.8 and will soon be histroy
    cat >>${SHELL_CONFIG_FILE} <<-EOF
GOPATH=$HOME/.go
PATH=${PATH}:${GOPATH}/bin

GO111MODULE=on
GOPROXY=${GO_PROXY}

export PATH GO111MODULE GOPROXY
EOF
    source ${SHELL_CONFIG_FILE}

}
install_mysql() {
    install_dependency "localinstall" 'https://dev.mysql.com/get/mysql80-community-release-el6-3.noarch.rpm'
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
skip_mysql_auth() {
    mysqld --skip-grant-tables --user=mysql &
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
    # this is a bug in mysql'lib,need to delete and recreate it
    rm -rf /var/lib/mysql/
    start_mysql && stop_mysql
    skip_mysql_auth  && sleep 2 && cat | mysql <<-EOF

SET GLOBAL validate_password.length = 4 ;
SET GLOBAL validate_password.number_count = 0;
SET GLOBAL  validate_password.policy = LOW;
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}'
EOF
    restart_mysql
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
install_yarn() {
    curl --silent --location https://rpm.nodesource.com/setup_10.x | sudo bash - || error_exit "failed to install nodejs"
    install_dependency "nodejs"

    curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo || error_exit "failed to install yarn"
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
    git clone "${BLOG_REPO}" "${BLOG_NAME}"
}

compile_frontend() {
    # that's so embarrassing,my machine memory is only 1 Gb.
    # so for successfuly to compile frontend,i need to shutdown mysql
    stop_mysql
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
    cd "${BLOG_ROOT_PATH}" && "./${BLOG_NAME}"
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
    echo "$@" && exit 1
}
open_port_in_firewall() {
    # centos6
    for PORT in "${NETWORK_PORTS[@]}"; do
        iptables -I INPUT -p tcp --dport ${PORT} -j ACCEPT
    done
    service iptables save && service iptables reload
}

##manage nginx

# change dir mode
# reload config
#
install_nginx() {
    wget http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
    rpm -ivh nginx-release-centos-6-0.el6.ngx.noarch.rpm
    install_dependency "nginx"
    nginx -v
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
   #开启和关闭gzip模式
    gzip on;
    
    #gizp压缩起点，文件大于1k才进行压缩
    gzip_min_length 1k;
    
    # gzip 压缩级别，1-9，数字越大压缩的越好，也越占用CPU时间
    gzip_comp_level 1;
    
    # 进行压缩的文件类型。
    gzip_types text/plain application/javascript application/x-javascript text/css application/xml text/javascript ;
    
    #nginx对于静态文件的处理模块，开启后会寻找以.gz结尾的文件，直接返回，不会占用cpu进行压缩，如果找不到则不进行压缩
    gzip_static on;
    
    # 是否在http header中添加Vary: Accept-Encoding，建议开启
    gzip_vary on;

    # 设置压缩所需要的缓冲区大小，以4k为单位，如果文件为7k则申请2*4k的缓冲区 
    gzip_buffers 2 4k;

    # 设置gzip压缩针对的HTTP协议版本
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
init
deploy_env
config_blog
open_port_in_firewall
run_blog
