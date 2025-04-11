import 'package:flutter/material.dart';
import 'package:weather/weather.dart';
import 'package:myapp/pages/const.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);
  Weather? _weather;
  final TextEditingController _controller = TextEditingController();
  String _cityName = 'Nairobi';

  @override
  void initState() {
    super.initState();
    _controller.text = _cityName;
    _fechWeather();
  }
  // to make the app color adapt with weather condition
  // final Map<String, List<Color>> _weatherGradients = {
  //   'Clear': [Color(0xFF47ABD8), Color(0xFF0071BC)],
  //   'Clouds': [Color(0xFF3F3F3F), Color(0xFF919191)],
  //   'Rain': [Color(0xFF616161), Color(0xFF005AA7)],
  //   'Thunderstorm': [Color(0xFF2C3E50), Color(0xFF4B6CB7)],
  //   'Snow': [Color(0xFFE3E3E3), Color(0xFFB3B3B3)],
  //   'Mist': [Color(0xFFAFAFAF), Color(0xFF696969)],
  //   'Default': [Color(0xFF1565C0), Color(0xFF1976D2)],
  // };

  void _fechWeather() {
    setState(() {
      _weather = null;
    });
    _wf
        .currentWeatherByCityName(_cityName)
        .then((weather) {
          setState(() {
            _weather = weather;
          });
        })
        .catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error fetching weather: $error'),
              backgroundColor: Colors.red[400],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        });
    _controller.clear();
  }

  // List<Color> _getWeatherGradients() {
  //   if (_weather == null) return _weatherGradients['default']!;
  //   return _weatherGradients[_weather!.weatherMain] ??
  //       _weatherGradients['Default']!;
  // }

  Color _getTextColor() {
    if (_weather?.weatherMain == 'Snow' || _weather?.weatherMain == 'Clouds') {
      return Colors.black87;
    }
    return Colors.black;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  _buildUi()//Container(
      //   // Background gradient based on weather condition
      //   decoration: BoxDecoration(
      //     gradient: LinearGradient(
      //       begin: Alignment.topCenter,
      //       end: Alignment.bottomCenter,
      //       colors: _getWeatherGradients(),
      //     ),
      //   ),
      //     child: _buildUi(),
      // ),
    );
  }

  Widget _buildUi() {
    final textColor = _getTextColor();
    // if (_weather == null) {
    //   return const Center(child: CircularProgressIndicator());
    // }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      // height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.bebasNeue(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Enter city name',
                      hintStyle: GoogleFonts.dancingScript(fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        setState(() {
                          _cityName = value;
                        });
                        _fechWeather();
                      }
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      setState(() {
                        _cityName = _controller.text;
                      });
                      _fechWeather();
                    }
                  },
                  icon: Icon(Icons.search),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child:
                _weather == null
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                      onRefresh: () async {
                        _fechWeather();
                      },
                      child: SingleChildScrollView(
                        child: Center(
                          child: Column(
                            children: [
                              AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(_weather!.areaName ?? '',textStyle: GoogleFonts.bebasNeue(color: textColor,fontWeight: FontWeight.w600,fontSize: 30),),
                                ],
                                totalRepeatCount: 20,
                              ),
                              // Center(
                                // child: Text(
                                //   _weather!.areaName ?? '',
                                //   style: GoogleFonts.bebasNeue(color: textColor,fontWeight: FontWeight.w600,fontSize: 30),
                                // ),
                              SizedBox(height: 18),
                              Image.network(
                                'https://openweathermap.org/img/wn/${_weather!.weatherIcon}@2x.png',
                                width: 100,
                                height: 100,
                              ),
                              SizedBox(height: 18),
                              Text(
                                _weather!.weatherDescription ?? '',
                                style: GoogleFonts.nunito(color: textColor,fontSize: 19),
                              ),
                              SizedBox(height: 18),
                              Text(
                                _weather!.weatherMain ?? '',
                                style: TextStyle(fontSize: 18, color: textColor, ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Humidity: ${_weather!.humidity}%',
                                style: TextStyle(fontSize: 17,color: textColor, ),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Wind Speed: ${_weather!.windSpeed} m/s',
                                style: TextStyle(fontSize: 16, color: textColor),
                              ),
                              SizedBox(height: 18),
                              Text(
                                'Pressure: ${_weather!.pressure} hPa',
                                style: TextStyle(fontSize: 15, color: textColor,),
                              ),
                              SizedBox(height: 18),
                              //Text('Visibility: ${_weather!.visibility} m'),
                            ],
                          ),
                        ),
                      ),
                    ),
          ),
          Text(
            'temperature: ${_weather?.temperature?.celsius?.toStringAsFixed(2)}',
            style: GoogleFonts.nunito(fontSize: 20,color: textColor,),
          ),
        ],
      ),
    );
  }
}
