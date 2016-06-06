import requests



greeting = 'Создать новый файл (1) или выбрать существующий (2) ?'
print (greeting)
choice = input()
if choice == '1':
    print ('Введите текст :')
    b = input()
    var = open('temp.txt', 'w')
    var.write (b)
    

    '''if choice == '2':
        print ('Укажите название файла :')
        b = input()
        var = open (b, 'r')
        b = var'''
    
    
text = b


payload = {'key': 'ad1a47b1-790b-45bc-a078-646ad1e01894',
           'text': text,
           'format': 'mp3',
           'lang': 'ru-RU',
           'speaker': 'zahar',}
request = requests.get('https://tts.voicetech.yandex.net/generate', params=payload)



s = request.content

q = open ('audio.mp3', 'wb')
q.write(s)
q.close()

var.close()
'print(request.status_code)'
'print(request.content)'
