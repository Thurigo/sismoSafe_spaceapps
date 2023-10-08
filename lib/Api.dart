import 'dart:convert';
import 'package:http/http.dart' as http;

Future<double> apiresquest() async {
  try {
    final http.Response httpResponse = await http.get(Uri.parse(
        "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&alertlevel=red&endtime"));

    if (httpResponse.statusCode == 200) {
      // Destructuring the roomId from the response
      print(json.decode(httpResponse.body)['features'][0]['properties']['mag']);
      return json.decode(httpResponse.body)['features'][0]['properties']['mag'];
    } else {
      throw Exception(
          'Failed to create meeting. Status code: ${httpResponse.statusCode}');
    }
  } catch (error) {
    throw Exception('An error occurred while creating the meeting: $error');
  }
}

class EarthquakeData {
  double mag;
  String place;
  int time;
  String alert;

  EarthquakeData({
    required this.mag,
    required this.place,
    required this.time,
    required this.alert,
  });
}

List<EarthquakeData> teermo = [];

Future<List<EarthquakeData>> getTremor() async {
  try {
    var url = Uri.parse(
        'https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&alertlevel=yellow&endtime');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> motos = data['features'];
      List<EarthquakeData> listademotos = [];

      motos.forEach((motos) {
        double mag = motos['properties']['mag'];
        String place = motos['properties']['place'];
        int time = motos['properties']['time'];
        String alert = motos['properties']['alert'];

        EarthquakeData motoObj =
            EarthquakeData(mag: mag, place: place, time: time, alert: alert);

        listademotos.add(motoObj);
      });

      print('oi');

      teermo = listademotos;

      return listademotos;
    } else {
      print('errado: ${response.statusCode}');
    }
  } catch (erro) {
    print('naooopooooooo ${erro}');
  }
  return teermo;
}
