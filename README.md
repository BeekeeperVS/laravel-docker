1) cp -rp .env.example .env
2) add all environment (env file settings)
3) copy dump.sql in mysql/dumps/${DB_DUMP_APP}
4) nginx conf.d settings
5) commands from makefile:
   - "make build" - first run the project
   - "make up" - start project (up all container)
   - "make stop" - stop project (stop all container)
   - "make set_hosts" - update hosts