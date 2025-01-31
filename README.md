# 15-cloudproj-01

## Задача YC
В ходе выполнения работы был написан проект на terraform который представлен в проекте

Nat-Instance:
![Screenshot 2025-01-31 143433](https://github.com/user-attachments/assets/5e5178bf-8ec0-49e5-bce8-96baa058e549)

Созданы фиртуальные машины:
![Screenshot 2025-01-31 143455](https://github.com/user-attachments/assets/0396559c-eba2-448c-8028-a1f2c5d18ddf)

После подключения на узел попадаем на виртуальную машину в приватной сети и попробуем одновить пакеты и сделать запрос для проверки интернета
```
 wget -q --spider https://www.yandex.ru && echo "Internet OK" || echo "No Internet"
```

![Screenshot 2025-01-31 143349](https://github.com/user-attachments/assets/e75077ef-de9a-45a4-a872-d63a2f6c15df)


*** Так как сейчас доступа к AWS задачу по работе с AWS будет выполнена в следующих работах
