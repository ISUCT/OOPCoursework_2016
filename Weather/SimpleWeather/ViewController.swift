
// Импортируем фреймворки
import UIKit
import CoreLocation
import SCLAlertView

// Создаем класс, подписываем его на делегаты, UIViewController - стандартный для ViewController и CLLocationManagerDelegate - для геолокации.
class ViewController: UIViewController, CLLocationManagerDelegate {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather" // Основной запрос к API
    private let openWeatherMapAPIKey = "fa3d632fc21c3dc944b6e5aabce59b72" // API ключ
    
    // Создаем переменные
    
    var icon: UIImage? // Иконка
    
    var backgroundColor: String? // Фон Background
    
    var refreshControl = UIRefreshControl() // Обновление
    
    var locationManager: CLLocationManager = CLLocationManager() // Геолокация
    
    // Создаем оутлеты - отображение объектов интерфейса
    
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var temp: UILabel!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var cloudLabel: UILabel!
    
    @IBOutlet weak var humidity: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var geoOutlet: UIBarButtonItem!
    
    @IBOutlet weak var searchOutlet: UIBarButtonItem!
    
    // viewDidLoad - Выполняется только 1 раз при запуске приложения или при повторной инициализации класса
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Делаем белый цвет кнопок в NavigationBar
        
        geoOutlet.tintColor = UIColor.whiteColor()
        searchOutlet.tintColor = UIColor.whiteColor()
        
        // Объявляем refresh - обновление
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.refreshControl.tintColor = UIColor.lightTextColor()
        self.scrollView.addSubview(refreshControl)
        
        // Выполняем проверку на наличие интернета (WIFI и Cellular). Если есть - определяем геолокацию и выводим информацию на экран. В противном случае выводим уведомление об отсутствии интренета.
        
        if Reachability.isConnectedToNetwork() == true {
        
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            
        } else {
            
            addGradient()
            let alertVC = UIAlertController(title: "Ошибка", message: "Отсутствует интернет соединение", preferredStyle: UIAlertControllerStyle.Alert)
            self.presentViewController(alertVC, animated: true, completion: nil)
        }
        
            
      
}
    // Функция размытия View -> срабатывает при отсутствии интернета.
    func addGradient() {
        
        let gradient:CAGradientLayer = CAGradientLayer()
        gradient.frame.size = self.view.frame.size
        gradient.colors = [UIColor.whiteColor().CGColor,UIColor.whiteColor().colorWithAlphaComponent(1).CGColor]
        self.view.layer.addSublayer(gradient)
        
    }

    // Функция определения геолокации (широта и долгота) -> останавливается при первом удачном получении координат. Содержит функцию "weatherFor", которая срабатывает и выводит информацию на экран по текущим координатам
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
            let currentLocation = locations.last! as CLLocation
            
            if (currentLocation.horizontalAccuracy > 0) {
            
            locationManager.stopUpdatingLocation()
            
            let coords = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude, currentLocation.coordinate.longitude)
            print(coords)
                self.weatherFor(coords)
        }
        
        
        }
    
    
    // При ошибке геолокации/ее отсутствии/или запрет на использование пользователем выводится стандартная информация о погоде по городу Москва
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
        getWeather("Moscow")
    }
    

    
    
    // Функция обновления -> обновляется по cityLabel - название города в интерфейсе.
    func refresh(sender:AnyObject) {
    
        
        self.getWeather(cityLabel.text!.stringByReplacingOccurrencesOfString(" ", withString: ""))
        
        self.refreshControl.endRefreshing()
    }
    
    
    // Функция, которая получает данные с openWeatherMap по геолокации.
    func weatherFor(geo: CLLocationCoordinate2D) {
        

        let session = NSURLSession.sharedSession() // Запускаем сессию
        
        // Выполняем API запрос
        
        let weatherRequestURL = NSURL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(geo.latitude)&lon=\(geo.longitude)&appid=fa3d632fc21c3dc944b6e5aabce59b72")
        
        // Принимаем JSON
        
        let dataTask = session.dataTaskWithURL(weatherRequestURL!) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                
                print("Error:\n\(error)")
            
            } else {
            
                
                do {
                    
                    let weather = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                    // Отображаем полученные данные в интерфейс в основном потоке.
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                       
                        
                        self.cityLabel.text = String(weather["name"]!)
                        
                        let temp = weather["main"]!["temp"]!! as! Int
                        
                        self.temp.text = String(temp - 273)
                        
                        self.cloudLabel.text = String("\(weather["weather"]![0]!["description"]!!)")
                        
                        self.countryLabel.text = String(weather["sys"]!["country"]!!)
                        
                        self.humidity.text = String("Влажность: \(weather["main"]!["humidity"]!!)%")
                        
                        let srtIcon = weather["weather"]![0]!["icon"]!!
                        self.icon = self.weatherIcon(srtIcon as! String)
                        self.imageView.image = self.icon
                        
                        let strBackground = weather["weather"]![0]!["icon"]!!
                        self.backgroundColor = String(self.backgroundImage(strBackground as! String))
                        self.view.backgroundColor = UIColor(patternImage: UIImage(named: self.backgroundColor!)!)
                        
                        if weather["weather"]![0]!["description"]!! as! String == "clear sky" {
                            self.cloudLabel.text = "Чистое небо"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "few clouds" {
                            self.cloudLabel.text = "Малооблачно"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "scattered clouds" {
                            self.cloudLabel.text = "Облачно"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "broken clouds" {
                            self.cloudLabel.text = "Малооблачно"
                        }
                        
                        
                        if weather["weather"]![0]!["description"]!! as! String == "shower rain" {
                            self.cloudLabel.text = "Ливень"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "rain" {
                            self.cloudLabel.text = "Дождь"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "thunderstorm" {
                            self.cloudLabel.text = "Гроза"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "snow" {
                            self.cloudLabel.text = "Снег"
                        }
                        
                        if weather["weather"]![0]!["description"]!! as! String == "mist" {
                            self.cloudLabel.text = "Туман"
                        }

                        
                        
                        
                    }
                }
                catch let jsonError as NSError {
                    
                    print("JSON error \(jsonError.description)")
                    
                }
            }
        }
        
        dataTask.resume()

        
        
    }
    

    // Аналогично, что и в предыдущей функции, только информацию получаем по названию города, а не геолокации
    
    func getWeather(city: String) {
        
        
        let session = NSURLSession.sharedSession()
        
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        
       
        
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let error = error {
                
                print("Error:\n\(error)")
            }
            else {
                
                do {
                    
                    let weather = try NSJSONSerialization.JSONObjectWithData(
                        data!,
                        options: .MutableContainers) as! [String: AnyObject]
                    
                        dispatch_async(dispatch_get_main_queue()) {
                            

                        self.cityLabel.text = String(weather["name"]!)
                            
                        let temp = weather["main"]!["temp"]!! as! Int
                        
                        self.temp.text = String(temp - 273)
                        
                        self.cloudLabel.text = String("\(weather["weather"]![0]!["description"]!!)")
                        
                        self.countryLabel.text = String(weather["sys"]!["country"]!!)
                        
                        self.humidity.text = String("Влажность: \(weather["main"]!["humidity"]!!)%")
                        
                        let srtIcon = weather["weather"]![0]!["icon"]!!
                        self.icon = self.weatherIcon(srtIcon as! String)
                        self.imageView.image = self.icon
                        
                        let strBackground = weather["weather"]![0]!["icon"]!!
                        self.backgroundColor = String(self.backgroundImage(strBackground as! String))
                        self.view.backgroundColor = UIColor(patternImage: UIImage(named: self.backgroundColor!)!)
                            
                            if weather["weather"]![0]!["description"]!! as! String == "clear sky" {
                                self.cloudLabel.text = "Чистое небо"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "few clouds" {
                                self.cloudLabel.text = "Малооблачно"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "scattered clouds" {
                                self.cloudLabel.text = "Облачно"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "broken clouds" {
                                self.cloudLabel.text = "Малооблачно"
                            }
                            
                            
                            if weather["weather"]![0]!["description"]!! as! String == "shower rain" {
                                self.cloudLabel.text = "Ливень"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "rain" {
                                self.cloudLabel.text = "Дождь"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "thunderstorm" {
                                self.cloudLabel.text = "Гроза"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "snow" {
                                self.cloudLabel.text = "Снег"
                            }
                            
                            if weather["weather"]![0]!["description"]!! as! String == "mist" {
                                self.cloudLabel.text = "Туман"
                            }
                        
                        
                    }
                }
                catch let jsonError as NSError {
                    
                    print("JSON error \(jsonError.description)")
                    
                }
            }
        }
        
        dataTask.resume()
        
        
    }
    

    
    
    // Кнопка поиска по городу, содержит сторонний фреймворк, интегрированный в проект при помощи cocoapods. Замена стандартному UIAlertController'у
    
    @IBAction func searchButton(sender: AnyObject) {
    
        let alert = SCLAlertView()
        let txt = alert.addTextField("Введите город")
        txt.textAlignment = .Center
        txt.keyboardType = .ASCIICapable
        alert.addButton("OK") {
            if txt.text != "" {
                
                self.getWeather(txt.text!.stringByReplacingOccurrencesOfString(" ", withString: ""))
            }
        }
        alert.showTitle("Введите город", subTitle: "", style: .Success, closeButtonTitle: "Отмена", duration: 0, colorStyle: 202020, colorTextButton: 0xFFFFFF)
        
    }
    
        
    // В данной функции выполняем перебор пришедшего ID иконки, и указываем соответствующее ей изображение. (По названию)
    
    func weatherIcon(strinIcon: String) -> UIImage {
        
        let imageName: String
        
        switch strinIcon {
        case "01d": imageName = "01d" // clear sky
        case "02d": imageName = "02d" // few clouds
        case "03d": imageName = "03d" // scattered clouds
        case "04d": imageName = "04d" // broken clouds
        case "09d": imageName = "09d" // shower rain
        case "10d": imageName = "10d" // rain
        case "11d": imageName = "11d" // thunderstorm
        case "13d": imageName = "13d" // snow
        case "50d": imageName = "50d" // mist
        case "01n": imageName = "01n"
        case "02n": imageName = "02n"
        case "03n": imageName = "03n"
        case "04n": imageName = "04n"
        case "09n": imageName = "09n"
        case "10n": imageName = "10n"
        case "11n": imageName = "11n"
        case "13n": imageName = "13n"
        case "50n": imageName = "50n"
            
            
        default: imageName = "none"
            
        }
        
        let iconImage = UIImage(named: imageName)
        return iconImage!
        
    }
    
    // Аналогичный перебор, только с background
    
    func backgroundImage(strinImage: String) -> String {
        
        let imageName: String
        
        switch strinImage {
        case "01d": imageName = "01dB"
        case "02d": imageName = "02dB"
        case "03d": imageName = "03dB"
        case "04d": imageName = "04dB"
        case "09d": imageName = "09dB"
        case "10d": imageName = "10dB"
        case "11d": imageName = "11dB"
        case "13d": imageName = "13dB"
        case "50d": imageName = "50dB"
        case "01n": imageName = "01nB"
        case "02n": imageName = "02nB"
        case "03n": imageName = "03nB"
        case "04n": imageName = "04nB"
        case "09n": imageName = "09nB"
        case "10n": imageName = "10nB"
        case "11n": imageName = "11nB"
        case "13n": imageName = "13nB"
        case "50n": imageName = "50nB"
        default:
            imageName = "01dB"
        }
        
        let backgroundColor = String(imageName)
        return backgroundColor
    }
    
    // Кнопка, которая отвечает за вывод информации по геолокации.
    
    @IBAction func checkGeo(sender: AnyObject) {
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    

        
}
    
    

