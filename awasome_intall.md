# Установка Awasome
## 1. Устанавливаем зависимости
### 1.1. X-сервер и драйверы
```
sudo pacman -S xorg-server xorg-drivers xorg-xinit xorg-xev
```
### 1.2. pulseaudio
```
sudo pacman -S pulseaudio
```
## 2. Awasome wm
### 2.1. Устанавливаем Awasome wm
```
sudo pacman -S awasome
```
### 2.2. Настраиваем  Awesome WM (Проверить)
Компируем конфиг xinitrc
```
cp /etc/X11/xinit/xinitrc ~/.xinitrc
cd ~nano .xinitrc
```
В конце дописываем
```
exec awesome
```
Добавляем строку
```
xrdb -merge ~/.Xresources &
```
Удалим, закомментируем ненужное. Образец файла .xinitrc
```
#!/bin/sh

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

xrdb -merge ~/.Xresources &

#twm &
#xclock -geometry 50x50-1+1 &
#xterm -geometry 80x50+494+51 &
#xterm -geometry 80x20+494-0 &
#exec xterm -geometry 80x66+0+0 -name login
exec awesome
```
Копирум default файлы конфигурации awesome в домашнюю директорию
```
cd ~
mkdir -p .config/awesome
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/
cp -r /usr/share/awesome/* ~/.config/awesome/
```
## 3. Устанавливаем пакеты
### 3.1. Устанавливаем шрифты:
```
sudo pacman -S ttf-liberation ttf-dejavu noto-fonts ttf-roboto ttf-droid
```
### 3.1 Установка NvChad
Требует шрифт `Nerd Font`
Зависимости:
```
sudo pacman -S node npm unzip
```
Установка NvChad
```
git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 && nvim
```
### 3.2. Устанавливаем пакеты для графического менеджера входа
```
sudo pacman -S slim
```
Подключаем менеджер входа
```
systemctl enable slim.service
```

