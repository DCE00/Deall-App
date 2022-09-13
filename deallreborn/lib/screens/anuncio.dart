class Anuncio {
  String description;
  int id;
  String company;
  String type;
  int distance;
  var rate;
  int fav;
  String qrInfo;

  //Anuncio(this.description, this.id, this.company, this.type, this.distance);

  Anuncio(String d, int i, String comp, String tag, int dist, var punt, int isfav, String infoQR) {
    this.description = d;
    this.id = i;
    this.company = comp;
    this.type = tag;
    this.distance = dist;
    this.rate = punt;
    this.fav = isfav;
    this.qrInfo = infoQR;
  }
}