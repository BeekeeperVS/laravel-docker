FROM mysql:8.0.19
RUN mkdir -p /var/lib/mysql-files
RUN mkdir -p /var/log/mysql/
RUN touch /var/log/mysql/slow-query.log && chown mysql:mysql /var/log/mysql/slow-query.log
