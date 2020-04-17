## What is this?
A blog written in Bootstrap + Vue and Gin (a golang web framework)

[Demo click here](https://xiulu.xyz)

## Supported feature
- [x] Responsive UI
- [x] Login
- [x] Edit article
- [x] Markdown preview
- [ ] Comment system

## How to Use?

Copy and paste the following line into your machine
```shell script
wget -q -O deploy.sh https://raw.githubusercontent.com/wljgithub/my-blog/master/manage.sh && sudo bash deploy.sh
```
Notice: This script only work on centos6.

And It is recommended that to run this script on a pure machine instance,to prevent unpredictable error

## What does the script actually do?

It will automatically install prerequisite enviroment,such as mysql,nginx,golang etc

And will configure them in proper way

After this script done,you can directly visit your own blog on the browser.

## License 
MIT


