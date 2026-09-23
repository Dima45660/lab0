#!/bin/bash


set -uo pipefail

#чтобы работало и с русскими буквами
export LC_ALL=C.UTF-8

BASE="lab0_script"

#чистим старую версию на слчай повторного запуска 
rm -rf "$BASE"
mkdir -p "$BASE"
cd "$BASE" || exit 1

mkdir -p claude_monet/bar
mkdir -p claude_monet/hall
mkdir -p claude_monet/office
mkdir -p claude_monet/storage
mkdir -p claude_monet/wine_cellar
mkdir -p kostya_room
mkdir -p empty_crates


cat > kostya_room/kostya_diary << 'EOF'
Костя открыл бар раньше обычного
Настя помогла расставить бокалы
Нагиев похвалил новый коктейль
Вечером друзья встретились после смены
EOF

cat > bar_message << 'EOF'
Бар открывается вместе с рестораном
Костя назначен ответственным за напитки
Вика ждёт отчёт об остатках
Нагиев приедет после восьми часов
EOF

cat > claude_monet/bar/cocktail_menu << 'EOF'
Фирменный коктейль от Кости
Лимонад для Насти без сахара
Классический напиток для постоянных гостей
Новый коктейль показать Вике вечером
EOF

cat > claude_monet/bar/evening_orders << 'EOF'
Столик два заказал три коктейля
Для банкета подготовить холодные напитки
Нагиев ждёт свой заказ у барной стойки
Последний заказ принимает Костя
EOF

cat > claude_monet/hall/reservations << 'EOF'
Столик четыре забронирован на вечер
У окна ждут постоянных гостей
Большой стол подготовить для банкета
Вика утвердит план рассадки
EOF

cat > claude_monet/hall/nastya_note << 'EOF'
Настя передаёт заказы Косте лично
Гостям за пятым столиком нужна вода
На банкете напитки подают после закусок
Последний заказ проверить перед закрытием
EOF

cat > claude_monet/office/vika_schedule << 'EOF'
Вика проверяет бар до открытия
Днём проходит встреча с поставщиком
Перед банкетом нужно сверить заказы
После смены Костя сдаёт отчёт
EOF

cat > claude_monet/storage/supplier_note << 'EOF'
Поставщик привезёт напитки утром
Новая партия вина отмечена в накладной
Костя должен проверить количество коробок
О повреждениях сразу сообщить Вике
EOF

cat > claude_monet/wine_cellar/nagiev_wine << 'EOF'
Нагиев попросил оставить любимое вино
Бутылку перенесли на отдельную полку
Костя отвечает за специальный заказ
Подать вино после приезда владельца
EOF

cat > claude_monet/wine_cellar/inventory << 'EOF'
В погребе осталось двенадцать бутылок вина
Красное вино заказано для банкета
Белое вино подадут к рыбе Феди
Костя проверит остатки после закрытия
EOF


echo "2. Установка прав доступа"

chmod 755 claude_monet
chmod 644 claude_monet/bar/cocktail_menu
chmod 750 claude_monet/wine_cellar
chmod 640 claude_monet/wine_cellar/nagiev_wine
chmod 755 claude_monet/hall
chmod 664 claude_monet/hall/reservations
chmod 640 claude_monet/office/vika_schedule
chmod 750 kostya_room
chmod 700 empty_crates


echo "3. Копирование, перемещение и создание ссылок"

# 1. Копировать файл в другой каталог с новым именем
cp kostya_room/kostya_diary claude_monet/office/bartender_report

# 2. Рекурсивно скопировать каталог под новым именем
cp -r claude_monet/wine_cellar claude_monet/storage/cellar_backup

# 3. Относительная симлинка внутри kostya_room
ln -s ../claude_monet/bar/evening_orders kostya_room/today_orders

# 4. Символическая ссылка в корне lab0 на каталог
ln -s claude_monet/bar bar_entrance

# 5. Жёсткая ссылка на файл bar_message
ln bar_message claude_monet/bar/owner_message

# 6. Объединить два файла в новый через cat + перенаправление
cat claude_monet/hall/reservations claude_monet/hall/nastya_note > claude_monet/hall/service_plan

# 7. Дописать содержимое одного файла в конец другого
cat claude_monet/storage/supplier_note >> claude_monet/wine_cellar/inventory

# 8. Переместить файл с переименованием
mv claude_monet/wine_cellar/nagiev_wine claude_monet/office/special_wine


echo "4. Поиск, фильтрация и обработка данных"

# 4.1: топ-5 обычных файлов по размеру (без 'report')
ls -laR . | grep '^-' | grep -v 'report' | sort -k5 -nr | head -n 5

# 4.2: строки с 'костя'/'настя', без 'отчёт', обратный алфавит, первые 6
grep -rhiE 'костя|настя' . | grep -v 'отчёт' | sort -r | head -n 6

# 4.3: сколько файлов (wine_cellar + cellar_backup) содержат 'вино'
grep -rl 'вино' claude_monet/wine_cellar claude_monet/storage/cellar_backup | wc -l

# 4.4: первая/последняя строки cocktail_menu и evening_orders (коктейль/заказ)
(head -qn1 claude_monet/bar/cocktail_menu claude_monet/bar/evening_orders; \
 tail -qn1 claude_monet/bar/cocktail_menu claude_monet/bar/evening_orders) \
 | grep -iE 'коктейл|заказ' | sort

# 4.5: service_plan, без 'послед', гост/заказ, обратный алфавит, топ-4, слов
grep -v 'послед' claude_monet/hall/service_plan | grep -iE 'гост|заказ' | sort -r | head -n4 | wc -w

# 4.6: обычные файлы с 2 жёсткими ссылками, сортировка по inode
ls -laiR . | awk '$2 ~ /^-/ && $3 == 2' | sort -k1,1n

# 4.7: символические ссылки, сортировка по имени (обратный алфавит), первая строка
ls -laR . | grep '^l' | sort -k9 -r | head -n1

echo "5. Удаление файлов, ссылок и каталогов"

rm kostya_room/kostya_diary
rm kostya_room/today_orders
rm bar_entrance
rm bar_message
rm claude_monet/bar/owner_message
rm claude_monet/storage/supplier_note
rmdir empty_crates
rm -r claude_monet/storage/cellar_backup
