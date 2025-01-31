# 15-cloudproj-01

## Задача YC
В ходе выполнения работы был написан проект на terraform который представлен в проекте

Nat-Instance:
![Screenshot 2025-01-31 143433](https://github.com/user-attachments/assets/ac84301d-e76e-4c3d-bc9f-9af050cc983f)

Созданы фиртуальные машины:
![Screenshot 2025-01-31 143455](https://github.com/user-attachments/assets/89f00883-cf59-48af-ae88-d3eb74358021)

После подключения на узел попадаем на виртуальную машину в приватной сети и попробуем одновить пакеты и сделать запрос для проверки интернета
```
 wget -q --spider https://www.yandex.ru && echo "Internet OK" || echo "No Internet"
```

![Screenshot 2025-01-31 143349](https://github.com/user-attachments/assets/e75077ef-de9a-45a4-a872-d63a2f6c15df)


*** Так как сейчас доступа к AWS задачу по работе с AWS будет выполнена в следующих работах
