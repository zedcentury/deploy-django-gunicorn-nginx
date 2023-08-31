# Deploy

* `install.sh` serverga birinchi marta kirilganda tizimni yangilash va kerakli paketlarni o'rnatib olish uchun ishga
  tushiriladi.
* `database.sh` proyekt uchun ma'lumotlar bazasini yaratadi.
* `project.sh` proyektni githubdan yuklab olib, sozlashlarni amalga oshiradi.
* `configuration.sh` serverda socket va service fayllarni yozadi, hamda nginx sozlamalarini amalga oshiradi.

Ishni boshlashdan avval `example.json` bo'yicha o'z `data.json` faylingizni yarating.

data.json strukturasi

* `repository` - github repository of project
* `db_password` - password of user
* `env`
    * `DEBUG` - DEBUG variable
    * `SECRET_KEY` - SECRET_KEY variable
    * `URL` - URL variable
* `url` - url of project
