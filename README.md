# ft_server
• Web server with Nginx, in only one docker container. The container OS is debian buster.
• Web server be able to run several services at the same time. The services are WordPress website, phpMyAdmin and MySQL. SQL database works with the WordPress and phpMyAdmin.
• Server able to use the SSL protocol.
• Depending on the url, server redirects to the correct website.
• Server is running with an autoindex.
# Using

Building the server `docker build -t server`

Starting the server `docker run -it --rm -p 80:80 -p 443:443 server`
