import 'package:flutter/material.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';  

void main() {
  runApp(const MyApp());
  
}



/*  Text Styles */
final h1 = TextStyle(fontFamily: 'SfFortune', fontSize: 110, color: white);
final h2Semi = TextStyle(fontFamily: 'Raleway', fontSize: 30, fontWeight: FontWeight.w800, color: white);

/* Colors */
Color white = Colors.white;
Color primary = Color.fromRGBO(0, 183, 146, 100).withOpacity(1);
Color secondary = Color.fromRGBO(9, 198, 204, 100).withOpacity(1);
Color darkBlue = Color.fromRGBO(0, 112, 135, 100).withOpacity(1);

/* Settings */
List presentationTypes = [
  'Tekli',
  'İkili',
];

/* Stopwatch Timer */

final mainTimer = StopWatchTimer(
  mode: StopWatchMode.countDown,
  onChange: (value) {
    final displayTime = StopWatchTimer.getDisplayTime(value);
    print('displayTime $displayTime');
  },
  onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
  onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
);

final breakTimer = StopWatchTimer(
  mode: StopWatchMode.countDown,
  onChange: (value) {
    final displayTime = StopWatchTimer.getDisplayTime(value);
    print('displayTime $displayTime');
  },
  onChangeRawSecond: (value) => print('onChangeRawSecond $value'),
  onChangeRawMinute: (value) => print('onChangeRawMinute $value'),
);

enum CountState {
  IDLE,
  COUNTING,
  BREAK,
  STOPPED
}

int mainMS = 780000;
int breakMS = 240000;

CountState state = CountState.IDLE;

bool isExpanded = false;

String type = presentationTypes[0];

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Divan Kronometre',
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}


class _HomeState extends State<Home> {
  

  @override
  void dispose() async{
    super.dispose();
    await mainTimer.dispose();
    await breakTimer.dispose();
  }

  @override
  void initState() {
    super.initState();

    mainTimer.setPresetTime(mSec: mainMS);
    breakTimer.setPresetTime(mSec: breakMS);
  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double rWidth = size.width/100;

    if(state != CountState.IDLE){
      primary = secondary;
    } else {
      primary = Color.fromRGBO(0, 183, 146, 100).withOpacity(1);
    }

    return Scaffold(
      backgroundColor: primary,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Divan Kronometre', style: h2Semi.apply(color: primary),),
        backgroundColor: white,
        elevation: 0,
      ),
      
      body: ListView(
            shrinkWrap: true,
            children: [
              SizedBox(height:rWidth*10),
              Column(
                children: [
                  Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StreamBuilder<int>(
                          stream: mainTimer.secondTime,
                          initialData: mainTimer.secondTime.value,
                          builder: (context, snapshot) {
                            final data = snapshot.data! * 1000;
                            return Text('''${StopWatchTimer.getDisplayTimeMinute(data)}:${StopWatchTimer.getDisplayTimeSecond(data)}''', style: h1,);
                          }
                        ),
                        StreamBuilder<int>(
                          stream: breakTimer.secondTime,
                          initialData: breakTimer.secondTime.value,
                          builder: (context, snapshot) {
                            final data = snapshot.data! * 1000;
                            return Text('''${StopWatchTimer.getDisplayTimeMinute(data)}:${StopWatchTimer.getDisplayTimeSecond(data)}''', style: h1.apply(fontSizeFactor: 0.5),);
                          }
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text('Sunum türü:', style: h2Semi.apply(fontSizeFactor: 0.8,)),
                    trailing: DropdownButton(
                      dropdownColor: secondary,
                      value: type,
                      isExpanded: false,
                      onChanged: (e) {
                        mainTimer.clearPresetTime();
                        breakTimer.clearPresetTime();
                        if(e == 'Tekli'){
                          /* Number 13 is chosen intentionally, GenclikDivani.length */
                          mainTimer.setPresetTime(mSec: 13*60*1000);
                          /* Number 4 is chosen intentionally, Sunu.length */
                          breakTimer.setPresetTime(mSec: 4*60*1000);
                        } else if(e == 'İkili'){
                          mainTimer.setPresetTime(mSec: 25*60*1000);
                          breakTimer.setPresetTime(mSec: 5*60*1000);
                        }
                        setState(() {
                          type = e.toString();
                        });
                      },
                      onTap: (){
                        setState(() {
                          isExpanded = !isExpanded;
                        });
                      },
                      
                      // Tekli, ikili
                      items: presentationTypes.map((e){
                        return DropdownMenuItem(
                          
                          value: e,
                          child: Text(e, style: h2Semi.apply(fontSizeFactor: 0.7, color: white),),
                        );
                      }).toList()
                    ),
                  ),
                  InkWell(
                    /* BAŞLAT */
                    onTap: (){
                      if(state == CountState.COUNTING){
                        mainTimer.onExecute.add(StopWatchExecute.stop);
                        setState(() {
                          state = CountState.STOPPED;
                        });
                      } else if(state == CountState.BREAK){
                        mainTimer.onExecute.add(StopWatchExecute.start);
                        breakTimer.onExecute.add(StopWatchExecute.stop);
                        setState(() {
                          state = CountState.COUNTING;
                        });
                      } else if(state == CountState.IDLE || state == CountState.STOPPED){
                        mainTimer.onExecute.add(StopWatchExecute.start);
                        setState(() {
                          state = CountState.COUNTING;
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      width: rWidth*80,
                      padding: EdgeInsets.symmetric(vertical: rWidth*5),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(state == CountState.COUNTING? 'Durdur': state == CountState.STOPPED || state == CountState.BREAK ? 'Devam Et': 'Başlat',style: h2Semi.apply(color: primary),),
                    ),
                  ),
                  state != CountState.IDLE? InkWell(
                    onTap: (){
                      if(state == CountState.COUNTING){
                        mainTimer.onExecute.add(StopWatchExecute.stop);
                        breakTimer.onExecute.add(StopWatchExecute.start);
                        setState(() {
                          state = CountState.BREAK;
                        });
                      } else if(state == CountState.BREAK){
                        /* mainTimer.onExecute.add(StopWatchExecute.stop); */
                        
                      } else if(state == CountState.IDLE){
                        /* mainTimer.onExecute.add(StopWatchExecute.start);
                        setState(() {
                          state = CountState.COUNTING;
                        }); */
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      width: rWidth*80,
                      padding: EdgeInsets.symmetric(vertical: rWidth*5),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text(state == CountState.COUNTING? 'Araver': 'Arada',style: h2Semi.apply(color: primary),),
                    ),
                  ): SizedBox(),

                  state != CountState.IDLE? InkWell(
                    onTap: (){
                      mainTimer.onExecute.add(StopWatchExecute.reset);
                      breakTimer.onExecute.add(StopWatchExecute.reset);
                        setState(() {
                          state = CountState.IDLE;
                        });
                      /* if(state == CountState.COUNTING){
                        mainTimer.onExecute.add(StopWatchExecute.stop);
                        breakTimer.onExecute.add(StopWatchExecute.start);
                        setState(() {
                          state = CountState.BREAK;
                        });
                      } else if(state == CountState.BREAK){
                        /* mainTimer.onExecute.add(StopWatchExecute.stop); */
                        
                      } else if(state == CountState.IDLE){
                        /* mainTimer.onExecute.add(StopWatchExecute.start);
                        setState(() {
                          state = CountState.COUNTING;
                        }); */
                      } */
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      alignment: Alignment.center,
                      width: rWidth*80,
                      padding: EdgeInsets.symmetric(vertical: rWidth*5),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Text('Bitir',style: h2Semi.apply(color: primary),),
                    ),
                  ): SizedBox(),
                ],
              ),
            ],
          ),
    );
  }
}