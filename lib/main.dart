import 'package:flutter/material.dart';
import 'dart:math';

import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.setAsset('audio/rain.mp3');
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      Rain(player: _audioPlayer),
      BassDiagram(
        player: _audioPlayer,
      ),
    ];
    return Scaffold(
      key: _key,
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              onTap: () {
                setState(() {
                  currentPage = 0;
                });
                _audioPlayer.setAsset('audio/rain.mp3');
                Navigator.pop(context);
              },
              leading: const Text('Rain'),
            ),
            ListTile(
              onTap: () {
                setState(() {
                  currentPage = 1;
                });
                _audioPlayer.setAsset('audio/supernova.mp3');
                Navigator.pop(context);
              },
              leading: const Text('Bass boosted'),
            ),
          ],
        ),
      ),
      body: Stack(children: [
        pages[currentPage],
        Positioned(
          top: 20,
          left: 20,
          child: IconButton(
            onPressed: () => _key.currentState!.openDrawer(),
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
          ),
        )
      ]),
    );
  }
}

class Rain extends StatefulWidget {
  const Rain({super.key, required this.player});
  final AudioPlayer player;

  @override
  State<Rain> createState() => _RainState();
}

class _RainState extends State<Rain> {
  var random = Random();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!isPlaying) {
          await widget.player.play();
          setState(() {
            isPlaying = true;
          });
        } else {
          await widget.player.stop();
          setState(() {
            isPlaying = false;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xff2B3A67),
          image: DecorationImage(
              image: AssetImage('img/forest.jpg'), fit: BoxFit.cover),
        ),
        child: Stack(children: [
          ...List.generate(130, (index) {
            var left = random.nextDouble() * MediaQuery.of(context).size.width;
            var randomBottom = random.nextDouble() * 200 + 2;
            var bottom = MediaQuery.of(context).size.height + randomBottom;
            var randomAnimate = (random.nextDouble() * 1200 + 300).round();
            var top = random.nextDouble() * MediaQuery.of(context).size.height +
                MediaQuery.of(context).size.height * 0.4;
            return Drop(
              left: left,
              bottom: bottom,
              randomAnimate: randomAnimate,
              top: top,
            );
          }),
        ]),
      ),
    );
  }
}

class Drop extends StatefulWidget {
  const Drop({
    super.key,
    required this.left,
    required this.bottom,
    required this.randomAnimate,
    required this.top,
  });
  final double left;
  final double bottom;
  final int randomAnimate;
  final double top;

  @override
  State<Drop> createState() => _DropState();
}

class _DropState extends State<Drop> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> top;
  late Animation<double> bottom;
  late Animation<double> opacity;
  var random = Random();

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        duration: Duration(milliseconds: widget.randomAnimate), vsync: this);

    top = Tween<double>(
      begin: widget.top,
      end: MediaQueryData.fromWindow(WidgetsBinding.instance.window)
              .size
              .height -
          10,
    ).animate(controller);
    bottom = Tween<double>(
      begin: widget.bottom,
      end: 0,
    ).animate(controller);

    opacity = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(controller);

    controller.repeat();

    controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom.value,
      left: widget.left,
      child: Opacity(
        opacity: opacity.value,
        child: Container(
          width: 1,
          height: 90,
          decoration: const BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(colors: [
                Color.fromRGBO(255, 255, 255, 0),
                Color.fromRGBO(255, 255, 255, 0.25)
              ])),
        ),
      ),
    );
  }
}

class BassDiagram extends StatefulWidget {
  const BassDiagram({super.key, required this.player});
  final AudioPlayer player;

  @override
  State<BassDiagram> createState() => _BassDiagramState();
}

class _BassDiagramState extends State<BassDiagram>
    with SingleTickerProviderStateMixin {
  final random = Random();
  bool isPlaying = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isPlaying) {
          widget.player.stop();
          setState(() {
            isPlaying = false;
          });
        } else {
          widget.player.play();
          setState(() {
            isPlaying = true;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 10),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('img/bass.jpg'),
            fit: BoxFit.cover,
          ),
          color: Color(0xff2B3A67),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              60,
              (index) => BassColumn(
                initialHeight: random.nextDouble() * 150 + 50,
                animationDuration: random.nextInt(1000) + 800,
                isPlaying: isPlaying,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BassColumn extends StatefulWidget {
  const BassColumn(
      {super.key,
      required this.initialHeight,
      required this.animationDuration,
      required this.isPlaying});
  final double initialHeight;
  final int animationDuration;
  final bool isPlaying;

  @override
  State<BassColumn> createState() => _BassColumnState();
}

class _BassColumnState extends State<BassColumn>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> height;
  late Animation<Color?> color;
  late Animation curve;

  @override
  void initState() {
    controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: widget.animationDuration));
    curve = CurvedAnimation(parent: controller, curve: Curves.ease);

    height = Tween<double>(begin: 0, end: widget.initialHeight)
        .animate(CurvedAnimation(parent: controller, curve: Curves.bounceOut));

    color = ColorTween(
            begin: const Color.fromRGBO(200, 200, 255, 1),
            end: const Color.fromRGBO(19, 52, 255, 1))
        .animate(controller);

    controller.forward();

    controller.addListener(() {
      if (widget.isPlaying) {
        setState(() {});
      }
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.reverse();
      }
      if (status == AnimationStatus.dismissed) {
        controller.forward();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5),
      color: color.value,
      width: 10,
      height: height.value,
    );
  }
}
