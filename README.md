# Ubuntu 14.04 LTS Atlas template for LAMP-based development

Ubuntu 14.04.3 (32-bit) LTS with Apache 2.4, MySQL 5.7, PHP 5.6 and Composer. Cloned from https://github.com/Szasza/vagrant-trusty64

Current versions at the time of the last commit:

- Apache 2.4.18
- MySQL 5.7.10
- PHP 5.6.16
- Composer 1.0-dev
- Supervisor

**Important information**

The Apache docroot is the /vagrant folder.

The MySQL root user has no password and is only enabled for via-socket connection, using auth_socket plugin.

Since PHP runs as an unprivileged user, MySQL cannot be accessed from PHP using root credentials - one should create an user in the app DB setup with proper privileges for security reasons anyway.

If CLI access is needed for that, please use `sudo mysql`.
