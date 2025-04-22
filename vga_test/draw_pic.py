from PIL import Image

# Размеры изображения
width = 640
height = 480

# Создаем новое изображение
img = Image.new('RGB', (width, height))

# Читаем данные из файла
with open('frame.txt', 'r') as f:
    # Читаем весь файл и разбиваем на строки, игнорируя множественные символы новой строки
    lines = [line.strip() for line in f.read().splitlines() if line.strip()]

# Проверяем, что количество строк совпадает с высотой
if len(lines) != height:
    raise ValueError(f"Ожидалось {height} строк, найдено {len(lines)}")

# Обрабатываем каждую строку
for y, line in enumerate(lines):
    # Разбиваем строку на числа
    numbers = list(map(int, line.split()))
    
    # Проверяем, что количество чисел в строке совпадает с шириной
    if len(numbers) != width:
        raise ValueError(f"В строке {y} ожидалось {width} чисел, найдено {len(numbers)}")
    
    for x, num in enumerate(numbers):
        # Извлекаем RGB компоненты из 24-битного числа
        r = (num >> 16) & 0xFF  # Красный (старшие 8 бит)
        g = (num >> 8) & 0xFF   # Зеленый (средние 8 бит)
        b = num & 0xFF          # Синий (младшие 8 бит)
        
        # Устанавливаем пиксель
        img.putpixel((x, y), (r, g, b))

# Сохраняем изображение
img.save('output.png')
print("Изображение сохранено как output.png")
