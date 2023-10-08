import 'dart:math' as math;
// flutter build apk --build-name=1.0 --

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:space_apps/Api.dart';
import 'dart:async';

void main() => runApp(MaterialApp(home: BankApp()));

class BankApp extends StatefulWidget {
  const BankApp({super.key});

  @override
  _BankAppState createState() => _BankAppState();
}

class _BankAppState extends State<BankApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late PageController _pageController = PageController();
  late Animation<double> _rotation;
  final cards = 4;

  bool _isCardDetailsOpened() => _controller.isCompleted;

  void _openCloseCard() {
    if (_controller.isCompleted) {
      _controller.reverse();
    } else if (_controller.isDismissed) {
      _controller.forward();
    }
  }

  int _getCardIndex() {
    return _pageController.hasClients ? _pageController.page!.round() : 0;
  }

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 320));
    _rotation = Tween(begin: 0.0, end: 90.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double contentPadding = 32;

    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 103, 99, 1),
      body: RefreshIndicator(
        onRefresh:
            _refreshData, // Chama a função _refreshData ao puxar para cima
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text(
                  'Home'.toUpperCase(),
                  style: TextStyle(
                    color: Colors
                        .white, // Altere para a cor desejada (branco, no seu caso)
                  ),
                ),
                leading: IconButton(
                    icon: Icon(Icons.menu_rounded, color: Colors.white),
                    onPressed: () {}),
                actions: [
                  IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {})
                ],
              ),
              builder: (_, child) {
                return Positioned(
                  top: 16 - (56 * _controller.value),
                  left: contentPadding - 16,
                  right: contentPadding,
                  child: Opacity(opacity: 1 - _controller.value, child: child),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              child: AppBar(
                elevation: 0,
                backgroundColor: const Color.fromARGB(0, 255, 255, 255),
                title: Text(
                  'Terremotos'.toUpperCase(),
                  style: TextStyle(
                    color: Colors.white, // Cor do texto em branco
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.close,
                      color: Colors.white), // Ícone de fechar em branco
                  onPressed: _openCloseCard,
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings,
                        color:
                            Colors.white), // Ícone de configurações em branco
                    onPressed: () {},
                  ),
                ],
              ),
              builder: (_, child) {
                return Positioned(
                  top: -32 + (32 * _controller.value),
                  left: contentPadding - 16,
                  right: contentPadding,
                  child: Opacity(opacity: _controller.value, child: child),
                );
              },
            ),
            Positioned(
              top: screenSize.height * .31,
              left: screenSize.width * .415,
              right: 0,
              height: 200,
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _controller.value > 0.5 ? 0 : 1,
                        child: SizedBox(
                          width: 100,
                          child: Row(
                            children: List.generate(cards, (i) {
                              final selected = _getCardIndex() == i;
                              return Container(
                                width: 6,
                                height: 6,
                                margin: EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color:
                                      selected ? Colors.white : Colors.white30,
                                  shape: BoxShape.circle,
                                ),
                              );
                            }),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Positioned(
              top: screenSize.height * .16,
              left: 0,
              right: 0,
              height: 200,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return PageView.builder(
                    itemCount: cards,
                    controller: _pageController,
                    clipBehavior: Clip.none,
                    physics: _isCardDetailsOpened()
                        ? NeverScrollableScrollPhysics()
                        : BouncingScrollPhysics(),
                    itemBuilder: (context, i) {
                      if (_getCardIndex() != i) return _Card();
                      return Transform.rotate(
                        angle: _rotation.value * math.pi / 180,
                        alignment: Alignment.lerp(
                          Alignment.center,
                          Alignment(-.7, -.6),
                          _controller.value,
                        ),
                        child: _Card(),
                      );
                    },
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              child: _CardStats(
                onItemPressed: _openCloseCard,
              ),
              builder: (context, child) {
                return Positioned(
                  top: screenSize.height * .2,
                  right: -180 + (280 * _controller.value),
                  child: Opacity(
                    opacity: _controller.value,
                    child: child,
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              child: Padding(
                padding: EdgeInsets.only(left: contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: contentPadding),
                          child: Text(
                            'Gráfico',
                            style: Theme.of(context)
                                .textTheme
                                .headline6!
                                .copyWith(
                                    color: Color.fromARGB(255, 255, 255, 255)),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(Icons.more_horiz, color: Colors.white),
                          onPressed: () {},
                        )
                      ],
                    ),
                    SizedBox(height: 16),
                    Flexible(
                      child: LineChart(sampleData1()),
                    ),
                  ],
                ),
              ),
              builder: (context, child) {
                return Positioned(
                  top: screenSize.height * .7 - (100 * _controller.value),
                  width: screenSize.width,
                  height: 300,
                  right: contentPadding,
                  child: Opacity(
                    opacity: _controller.value,
                    child: child,
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _controller,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Erthquake',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.sort_sharp,
                            color: Color.fromARGB(255, 255, 255, 255)),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: todayTransactions.length,
                      physics: BouncingScrollPhysics(),
                      separatorBuilder: (_, i) {
                        return Divider(
                          color: Colors.white.withOpacity(1),
                          indent: 34 * 2.0,
                        );
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: TransactionWidget(todayTransactions[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
              builder: (context, child) {
                final topPadding = screenSize.height * .46;
                return Positioned(
                  top: topPadding + (200 * _controller.value),
                  bottom: 0,
                  left: contentPadding,
                  right: contentPadding,
                  child: Opacity(
                    opacity: 1 - _controller.value,
                    child: child,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(60, 149, 154, 1),
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: _openCloseCard,
      ),
    );
  }

  Future<void> _refreshData() async {
    // Aguarde um pequeno período de tempo para simular uma operação de recarregamento.
    await Future.delayed(Duration(seconds: 2));

    // Navegue para a mesma página novamente para recarregar.
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) => BankApp()));
  }

  LineChartData sampleData1() {
    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
      ),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (BuildContext context, double value) =>
              const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          margin: 10,
          getTitles: (value) {
            switch (value.toInt()) {
              case 2:
                return 'Jan';
              case 7:
                return 'Feb';
              case 12:
                return 'Mar';
            }
            return '';
          },
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (BuildContext context, double value) =>
              const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return '';
              case 2:
                return '';
              case 3:
                return '';
              case 4:
                return '';
            }
            return '';
          },
          margin: 8,
          reservedSize: 30,
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(
            color: Color.fromARGB(255, 0, 0, 0),
            width: 4,
          ),
          left: BorderSide(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          right: BorderSide(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
          top: BorderSide(
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      minY: 0,
      lineBarsData: linesBarData1(),
    );
  }

  List<LineChartBarData> linesBarData1() {
    final lineChartBarData1 = LineChartBarData(
      spots: [
        FlSpot(0, 0),
        FlSpot(earthquakes1[0].date.day.toDouble(), 6.8),
        FlSpot((earthquakes1[0].date.day.toDouble() + 5), 0),
      ],
      isCurved: true,
      colors: [
        const Color(0xff4af699),
      ],
      barWidth: 8,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(
        show: false,
      ),
    );

    return [
      lineChartBarData1,
    ];
  }
}

double comnras = 0;
double dsada = 0;

class _CardStats extends StatelessWidget {
  const _CardStats({Key? key, required this.onItemPressed}) : super(key: key);

  final VoidCallback onItemPressed;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<double>(
      future: apiresquest(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          double comnras = snapshot.data!;
          dsada = comnras;

          final bodyText = Theme.of(context).textTheme.bodyText1!.copyWith(
                color: const Color.fromARGB(255, 249, 249, 249),
              );
          return Container(
            width: 180,
            height: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: '',
                    style: bodyText.copyWith(
                      fontSize: 24,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    children: [
                      TextSpan(
                        text: 'Marrocos',
                        style: bodyText.copyWith(
                          fontSize: 32,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: onItemPressed,
                  horizontalTitleGap: 0,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.graphic_eq_rounded,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  title: Text(
                    'Magnitude: ${comnras.toStringAsFixed(2)}',
                    style: bodyText,
                  ),
                ),
                ListTile(
                  onTap: onItemPressed,
                  horizontalTitleGap: 0,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.calendar_month,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  title: Text(
                    'Data: ${earthquakes1[0].date.month}/ ${earthquakes1[0].date.day}',
                    style: bodyText,
                  ),
                ),
                ListTile(
                  onTap: onItemPressed,
                  horizontalTitleGap: 0,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.flag,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                  title: Text(
                    'Alerta: ${earthquakes1[0].description}',
                    style: bodyText,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Tratamento de erro ou carregamento de dados vazio
          return const Center(
            child: Text('Erro ao carregar dados'),
          );
        }
      },
    );
  }
}

Future<List<EarthquakeData>> teer = getTremor();

class _Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyText1!.copyWith(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 24,
        );

    var dsadsa;
    dsada;
    return Container(
      width: MediaQuery.of(context).size.width * .85,
      height: 190,
      padding: EdgeInsets.all(32),
      margin: EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
          color: const Color.fromRGBO(60, 149, 154, 1),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(31, 248, 248, 248),
              blurRadius: 16,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Earthquake Scale'.toUpperCase(), style: textStyle),
              SizedBox(height: 6),
              Text(dsada.toString(), style: textStyle),
            ],
          ),
          Spacer(),
          Text(
            'Marrocos - Africa',
            style: textStyle.copyWith(
              wordSpacing: 10,
              letterSpacing: 6,
            ),
          )
        ],
      ),
    );
  }
}

class TransactionWidget extends StatelessWidget {
  const TransactionWidget(this.transaction);

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.bodyText1!.copyWith(
          color: Colors.white70,
        );
    final captionStyle = Theme.of(context).textTheme.bodyText2!.copyWith(
          color: Color.fromARGB(255, 0, 0, 0).withOpacity(.6),
        );

    return SizedBox(
      height: 54,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning,
              color: Colors.white.withOpacity(.4),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(transaction.title, style: headerStyle),
              SizedBox(height: 4),
              Text(transaction.description, style: captionStyle),
            ],
          ),
          Spacer(),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('- ${transaction.amount}', style: headerStyle),
              SizedBox(height: 4),
              Text(transaction.getTime(), style: captionStyle),
            ],
          ),
          Icon(
            Icons.error_outline, // Ícone de aviso (warning)
            color: Colors.red, // Cor do ícone de aviso (vermelho, por exemplo)
            size: 24, // Tamanho do ícone
          ),
        ],
      ),
    );
  }
}

class Transaction {
  final String title;
  final String description;
  final double amount;
  final DateTime date;
  final String iconUrl;

  Transaction({
    required this.title,
    required this.description,
    required this.amount,
    required this.date,
    required this.iconUrl,
  });

  String getTime() => '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')} '
      '${date.hour >= 0 && date.hour <= 12 ? 'AM' : 'PM'}';
}

List<Transaction> todayTransactions = [
  Transaction(
    title: 'China',
    description: 'Red',
    amount: 5.3,
    iconUrl: '',
    date: DateTime(2023, 16, 3),
  ),
  Transaction(
    title: 'Marrocos',
    description: 'Red',
    amount: 2.3,
    iconUrl: '',
    date: DateTime(2023, 8, 8),
  ),
  Transaction(
    title: 'Shibuya - Japan',
    description: 'yellow',
    amount: 2.300,
    iconUrl: '',
    date: DateTime(2021, 06, 30),
  ),
  Transaction(
    title: 'San Francisco - USA',
    description: 'Green',
    amount: 0.50,
    iconUrl: '',
    date: DateTime(2021, 06, 30),
  ),
  Transaction(
    title: 'Chile',
    description: 'yellow',
    amount: 2.00,
    iconUrl: '',
    date: DateTime(2021, 06, 30),
  ),
];

class Earthquake {
  final String cityName;
  final double magnitude;
  final DateTime date;
  final String description;

  Earthquake({
    required this.cityName,
    required this.magnitude,
    required this.date,
    required this.description,
  });
  String getTime() => '${date.hour.toString().padLeft(2, '0')}:'
      '${date.minute.toString().padLeft(2, '0')} '
      '${date.hour >= 0 && date.hour <= 12 ? 'AM' : 'PM'}';
}

List<Earthquake> earthquakes1 = [
  Earthquake(
    cityName: 'Shibuya - Japan',
    magnitude: 2.3,
    date: DateTime(2023, 8, 8),
    description: 'Red',
  ),
  Earthquake(
    cityName: 'Los Angeles - USA',
    magnitude: 3.7,
    date: DateTime(2023, 9, 25),
    description: 'Moderate',
  ),
  Earthquake(
    cityName: 'San Francisco - USA',
    magnitude: 4.5,
    date: DateTime(2023, 8, 15),
    description: 'Significant',
  ),
  // Adicione mais terremotos conforme necessário.
];
