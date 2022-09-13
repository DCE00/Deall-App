import 'package:deallreborn/screens/cardsadv/details_card.dart';
import 'package:deallreborn/screens/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileCardAlignment extends StatelessWidget {
  final int cardNum;

  ProfileCardAlignment(this.cardNum);
  @override
  Widget build(BuildContext context) {
    int id = anuncios[cardNum].id;
    return Card(
      child: Stack(
        children: <Widget>[
          SizedBox.expand(
            child: Material(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                  'http://10.6.40.102:8079/getAnnouncementImage/$id',
                  fit: BoxFit.cover),
              //child: Image.asset('assets/images/portrait.jpg', fit: BoxFit.cover),
            ),
          ),
          SizedBox.expand(
            child: Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.center,
                      end: Alignment.bottomCenter)),
            ),
          ),
          Container(
            child: RatingBarIndicator(
              rating: anuncios[cardNum].rate.toDouble(),
              itemBuilder: (context, index) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              itemCount: 5,
              itemSize: 50.0,
              direction: Axis.horizontal,
            ),
          ),
          if (anuncios[cardNum].fav == 1)
          InkWell(
            splashColor: Colors.blue.withAlpha(30),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Details(cardNum)),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(anuncios[cardNum].company,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.w700)),
                    Padding(padding: EdgeInsets.only(bottom: 8.0)),
                    if (anuncios[cardNum].distance != -1)
                      Text(anuncios[cardNum].distance.toString() + ' mts.',
                          textAlign: TextAlign.start,
                          style: TextStyle(color: Colors.white)),
                  ],
                )),
          )
        ],
      ),
    );
  }
}
