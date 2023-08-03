# Установка Arch linux
## 1. Перед установкой
### 1.1. Обновить ключи для всей системы (Не обязательно)
Инициализация
```
sudo pacman-key --init
```
Получить ключи из репозитория
```
sudo pacman-key --populate archlinux
```
Проверить текущие ключи на актуальность
```
sudo pacman-key --refresh-keys
```
Обновить ключи для всей системы
```
sudo pacman -Sy
```
### 1.2. Установка раскладки клавиатуры (Не обязательно)
```
loadkeys ru
setfont cyr-sun16
```
### 1.3. Проверка режима загрузки (Не обязательно)
```
ls /sys/firmware/efi/efivars
```
Если содержимое отображается без каких-либо ошибок, система загружена в режиме `UEFI`. Если же такого каталога не существует, возможно, система загружена в режиме `BIOS` (или `CSM`). 
### 1.4. Синхронизация системных часов (Не обязательно)
Чтобы удостовериться, что время задано правильно
```
timedatectl status
```
Установка региона
```
timedatectl set-timezone Europe/Kirov
```
Синхронизация времени по сети
```
timedatectl set-ntp true
```
### 1.5. Разметка дисков
Когда запущенная система распознает накопители, они становятся доступны как блочные устройства, например, `/dev/sda`, `/dev/nvme0n1` или `/dev/mmcblk0`. Чтобы посмотреть их список, используйте:
```
lsblk
```
или 
```
fdisk -l
```
Результаты, оканчивающиеся на `rom`, `loop` и `airoot`, можно игнорировать.
На выбранном накопителе должны присутствовать следующие разделы: 
- Раздел для корневого каталога `/`
- Для загрузки в режиме `UEFI` также необходим системный раздел `EFI`.

Разбивка диска
```
fdisk /dev/диск_для_разметки
```


**Примечание**:
- Если диск не отображается, убедитесь, что контроллер диска не находится в режиме RAID.
- Если диск, с которого планируется загрузка системы, уже содержит системный раздел EFI — не создавайте новый раздел, а используйте существующий.
- Подкачка может быть размещена в файле подкачки, если файловая система поддерживает его.

### 1.5.1. Примеры схем
#### UEFI с GPT
| Точка монтирования   | Раздел                  | Тип раздела          | Рекомендуемый размер |
| ---------------------|-------------------------|----------------------|----------------------|
|/mnt/boot или /mnt/efi|/dev/системный_раздел_efi|системный раздел EFI  |Минимум 300 МиБ       |
|[SWAP]                |/dev/раздел_подкачки     |Linux swap            |Более 512 МиБ         |
|/mnt                  |/dev/корневой_раздел 	 |Linux x86-64 root (/) |Остаток	           |
#### BIOS с MBR
| Точка монтирования   | Раздел                  | Тип раздела          | Рекомендуемый размер |
| ---------------------|-------------------------|----------------------|----------------------|
|[SWAP]                |/dev/раздел_подкачки     |Linux swap            |Более 512 МиБ         |
|/mnt                  |/dev/корневой_раздел 	 |Linux                 |Остаток	           |

### 1.6. Форматирование разделов
Когда новые разделы созданы, каждый из них необходимо отформатировать в подходящую файловую систему.
```
mkfs.ext4 /dev/корневой_раздел
```
или
```
mkfs.btrfs /dev/корневой_раздел
```
Если вы создали раздел для подкачки (`swap`), инициализируйте его: 
```
mkswap /dev/раздел_подкачки
```
Если вы создали системный раздел `EFI`, отформатируйте его в `FAT32` 
**Важно**: Выполняйте форматирование, только если вы создали новый раздел в процессе разметки. Если системный раздел EFI уже существует, его форматирование уничтожит загрузчики других установленных операционных систем.
```
mkfs.fat -F32 /dev/системный_раздел_efi
```
### 1.7. Монтирование разделов
Смонтируйте корневой раздел в каталог /mnt. Например, если корневой раздел — `/dev/корневой_раздел`, выполните следующую команду: 
```
mount /dev/корневой_раздел /mnt
```
Создайте точки монтирования для всех остальных разделов (например, /mnt/efi) и примонтируйте соответствующие разделы.
**Совет**: Команда mount, запущенная с опцией `--mkdir`, автоматически создаст требуемую точку монтирования. Можно создать их и вручную с помощью mkdir.
Для UEFI примонтируйте системный раздел EFI: 
```
mount --mkdir /dev/Системный_раздел_EFI /mnt/boot/EFI
```
Если вы ранее создали раздел подкачки (`swap`), активируйте его с помощью swapon:
```
swapon /dev/раздел_подкачки
```
## 2. Установка
### 2.1. Выбор зеркал
Пакеты для установки должны скачиваться с серверов-зеркал, прописанных в файле `/etc/pacman.d/mirrorlist`. В установочном образе, после подключения к сети, `reflector` обновит список зеркал (выбрав 200 наиболее актуальных HTTPS-зеркал) и отсортирует их по скорости загрузки. 
```
reflector --sort rate -l 200 --save /etc/pacman.d/mirrorlis
```
Чем выше зеркало расположено в списке, тем больший приоритет оно имеет при скачивании пакета. Вы можете проверить этот файл и, при необходимости, `отредактировать` его вручную, переместив наверх наиболее географически близкие зеркала. При этом также учитывайте и другие критерии.

Позже pacstrap скопирует этот файл в новую систему, так что это действительно стоит сделать. 
### 2.2. Установка основных пакетов
Используйте скрипт `pacstrap`, чтобы установить пакет `base`, `ядро Linux` и прошивки часто встречающихся устройств:
```
pacstrap -K /mnt base base-devel linux linux-firmware
```
**Совет**:
- linux можно заменить на другой желаемый пакет ядра. Можно вообще не устанавливать ядро, если установка происходит в контейнере.
- Можно пропустить установку пакета прошивок, если установка происходит в контейнере или виртуальной машине.
- `base-devel` для сборки пакетов (опционально)

## 3. Настройка системы
### 3.1. Fstab
Сгенерируйте файл fstab (используйте ключ -U или -L, чтобы для идентификации разделов использовались UUID или метки, соответственно):
```
genfstab -U /mnt >> /mnt/etc/fstab
```
После этого проверьте файл `/mnt/etc/fstab` и отредактируйте его в случае необходимости. 

### 3.2. Chroot
Перейдите к корневому каталогу новой системы:
```
arch-chroot /mnt
```
### 3.3 Часовой пояс
Задайте часовой пояс: 
```
ln -sf /usr/share/zoneinfo/Регион/Город /etc/localtime
```
Запустите `hwclock`, чтобы сгенерировать /etc/adjtime: 
```
hwclock --systohc --utc
```
или если используется вместе с windows
```
hwclock --systohc --localtime
```
### 3.4 Локализация
Отредактируйте файл `/etc/locale.gen`, раскомментировав `en_US.UTF-8 UTF-8` и другие необходимые локали (например, `ru_RU.UTF-8 UTF-8`), 
```
vim /etc/locale.gen
```
после чего сгенерируйте их:
```
locale-gen
```
Создайте файл `locale.conf` и задайте переменной `LANG` необходимое значение: 
```
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
```
Если вы меняли раскладку клавиатуры, сделайте это изменение постоянным в файле `vconsole.conf`. Также добавьте шрифт для консоли с поддержкой кириллицы: 
```
vim /etc/vconsole.conf
```
Настройка сети
```
KEYMAP=ru
FONT=cyr-sun16
```
### 3.5. Настройка сети
Создайте файл `hostname`:
```
echo "arch-pc" > /etc/hostname
```
Установите NetworkManager
```
pacman -S networkmanager
```
 
### 3.6. Initramfs
Как правило, создание нового образа initramfs не требуется, поскольку pacstrap автоматически запускает `mkinitcpio` после установки пакета `ядра`.
Если вы используете `LVM`, `шифрование системы` или `RAID`, отредактируйте файл `mkinitcpio.conf` и пересоздайте образ initramfs:
```
mkinitcpio -P
```
### 3.7. Пароль суперпользователя
Установите `пароль` суперпользователя:
```
passwd
```
### 3.8. Загрузчик
Установите `загрузчик` с поддержкой Linux. 
#### 3.8.1. GRUB для Bios
```
pacman -S grub
grub-install /dev/Диск_системы
```
#### 3.8.2. GRUB для UEFI
```
pacman -S grub efibootmgr
grub-install
```
#### 3.8.3. Микрокод
Если вы используете процессор Intel или AMD, включите также обновление `микрокода`. 
**Для процессоров AMD установите пакет amd-ucode.**
```
pacman -S amd-ucode
```
**Для процессоров Intel установите пакет intel-ucode.** 
```
pacman -S intel-ucode
```
#### 3.8.3 Автоматическая конфигурация (grub-mkconfig)
```
grub-mkconfig -o /boot/grub/grub.cfg
```
### 3.9 Создание пользователя
Добавляем пользователя `username`
```
useradd -m -g users -G wheel -s /bin/bash username
```
Задаем пользователю `username` пароль
```
passwd username
```
### 3.10. Установка sudo
Установить sudo
```
pacman -S sudo
```
Открыть конфиг для редактирования
```
EDITOR=vim visudo
```
Раскоментировать строчку
```
# %wheel ALL=(ALL) ALL
```
Должно стать:
```
%wheel ALL=(ALL) ALL
```
Или добавте строчку
```
имя_пользователя All=(ALL) ALL
```
Должно стать:
```
root All=(ALL) ALL
имя_пользователя All=(ALL) ALL
```
## 5 Установка дополнительных утилит
### 5.1 Установка PipeWire
Установите pipewire
```
pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
```
Активируйте службы
```
systemctl --user enable pipwire.service
systemctl --user enable pipewire-pulse
```
`(Опцианально)` Установки pulsemixer
```
pacman -S pulsemixer
```
### 5.1 Установка шрифтов Noto
```
pacman -Syu noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-noto-nerd 
```
