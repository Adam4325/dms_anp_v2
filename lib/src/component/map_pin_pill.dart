import 'package:dms_anp/src/model/PinInformation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MapPinPillComponent extends StatefulWidget {
  final double pinPillPosition;
  final PinInformation currentlySelectedPin;

  const MapPinPillComponent({
    Key? key,
    required this.pinPillPosition,
    required this.currentlySelectedPin,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => MapPinPillComponentState();
}

class MapPinPillComponentState extends State<MapPinPillComponent> {
  @override
  Widget build(BuildContext context) {
    var acc = widget.currentlySelectedPin.acc.toString() == '1' ? "ON" : "OFF";
    return AnimatedPositioned(
      bottom: widget.pinPillPosition,
      top: 0,
      right: 0,
      left: 0,
      duration: Duration(milliseconds: 200),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.all(20),
          height: 150,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(11)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    blurRadius: 10,
                    offset: Offset.zero,
                    color: Colors.grey.withOpacity(0.5))
              ]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Container(
              //   width: 50, height: 50,
              //   margin: EdgeInsets.only(left: 10),
              //   child: ClipOval(child: Image.asset(widget.currentlySelectedPin.avatarPath, fit: BoxFit.cover )),
              // ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        //margin: EdgeInsets.all(5),
                        child: InkWell(
                          onTap: () {
                            Share.share(
                                'https://www.google.com/maps?q=${widget.currentlySelectedPin.lat},${widget.currentlySelectedPin.lon}&amp;t=m&amp;hl=en');
                          },
                          child: Text(
                              'Addr: ${widget.currentlySelectedPin.locationName}',
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color:
                                      widget.currentlySelectedPin.labelColor)),
                        ),
                      ),
                      //Text('Addr: ${widget.currentlySelectedPin.locationName}', style: TextStyle(color: widget.currentlySelectedPin.labelColor)),
                      Text(
                          'Nopol: ${widget.currentlySelectedPin.nopol.toString()}, Acc: $acc',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Text(
                          'GpsTime: ${widget.currentlySelectedPin.gps_time.toString()}',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Text(
                          'NoDo: ${widget.currentlySelectedPin.no_do.toString()}',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                      Text(
                          'KetStatusDo: ${widget.currentlySelectedPin.ket_status_do.toString()}',
                          style: TextStyle(fontSize: 14, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              // Padding(
              //   padding: EdgeInsets.all(15),
              //   child: Image.asset(widget.currentlySelectedPin.pinPath, width: 50, height: 50),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
