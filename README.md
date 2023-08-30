# Deploy

* `install.sh` serverga birinchi marta kirilganda tizimni yangilash va kerakli paketlarni o'rnatib olish uchun ishga
  tushiriladi.
* `database.sh` proyekt uchun ma'lumotlar bazasini yaratadi.
* `project.sh` proyektni githubdan yuklab olib, sozlashlarni amalga oshiradi.
* `configuration.sh` serverda socket va service fayllarni yozadi, hamda nginx sozlamalarini amalga oshiradi.

Ishni boshlashdan avval `example.json` bo'yicha o'z `data.json` faylingizni yarating.

* `db` - database configuration
    * `name` - name of database
    * `user` - user of database
    * `password` - password of database
* `project` - project configuration
    * `repository` - github repository of project
    * `name` - name of project
    * `env` - environment variables of project
        * `DEBUG` - DEBUG variable
        * `SECRET_KEY` - SECRET_KEY variable
        * `ALLOWED_HOSTS` - ALLOWED_HOSTS variable
        * `URL` - URL variable
* `configuration` - server configuration
    * `filename` - filename of socket and service files
    * `server_name` - server name
